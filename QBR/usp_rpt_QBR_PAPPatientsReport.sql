IF(OBJECT_ID('dbo.usp_rpt_QBR_PAPPatientsReport') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_PAPPatientsReport
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_PAPPatientsReport] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2025-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 0
	EXEC dbo.[usp_rpt_QBR_PAPPatientsReport] @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON 
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED
        
	/***************************************************************************      
	* PAP Patients     
	***************************************************************************/
	--DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	--SET @StartDate = '2025-01-01'
	--SET @EndDate = '2025-08-31'

	IF(OBJECT_ID('tempdb..#PAPPatients') IS NOT NULL)
		DROP TABLE #PAPPatients
	
	;WITH ClosedReimCases
		AS(
			SELECT DISTINCT C1.PatientId,C1.Id AS CaseId
				 --, C1.CreatedDate
				 , C1.CloseDate AS ReimCaseClosedDate
				 , ISNULL(CAT.CategoryName,'UnKnown') AS Reason
				 , ROW_NUMBER() OVER (PARTITION BY C1.PatientId ORDER BY C1.CloseDate DESC) AS SNo
			  FROM dbo.Cases C1
			  LEFT JOIN dbo.Categories CAT
	            ON C1.OtherCaseState = CAT.Id
			 WHERE C1.EnrollmentTypeId = 1 --Reimbursement
				AND C1.CaseStateId = 4 -- Closed
				--ORDER BY C1.PatientId,C1.Id
		)

	SELECT T.PatientId,T.PAPCaseId,ReimCaseID--, [Referral received date]
		 , T.CreatedDate AS CaseCreatedDate
		 , FORMAT(T.CreatedDate,'MMM-yyyy') AS DateYYYYMM, FORMAT(T.CreatedDate,'yyyyMM') AS DateYYYYMMNum
		 , Reason, PY.PayerName AS Payer,'How many patients on PAP and reason' AS Category
	 INTO #PAPPatients	
	 FROM 		
		 (
			SELECT C.PatientId,C.Id AS PAPCaseId,C1.CaseId AS ReimCaseID
				 , C.CreatedDate
				 --, C.EnrollmentDate AS [Referral received date]
				 , C1.Reason
				 , C1.CaseId AS CaseIdClosed
				 , C1.ReimCaseClosedDate
				 , ROW_NUMBER() OVER (PARTITION BY C.PatientId ORDER BY C.CreatedDate DESC) AS SNo	  
			  FROM dbo.Cases C
			 INNER JOIN ClosedReimCases C1
				ON C.PatientId = C1.PatientId
				AND C1.SNo = 1
			 INNER JOIN dbo.EnrollmentTypes ET
				ON C.EnrollmentTypeId = ET.Id			  	
			 WHERE ET.EnrollmentTypeCode = 'PAP'
			   AND C.CreatedDate > C1.ReimCaseClosedDate
			   AND C.CreatedDate BETWEEN @StartDate AND @EndDate	
			 
		 ) AS T
	  LEFT JOIN dbo.Insurances I
	    ON I.CaseId = T.PAPCaseId
	   AND I.InsuranceTypeId = 6
	   AND I.IsActive = 1
	  LEFT JOIN dbo.Plans P                                                                     
		ON P.Id = I.PlanId                                                                          
	  LEFT JOIN dbo.Payers PY                          
		ON P.PayerId = PY.Id	  		
	 WHERE T.SNo = 1
	 ORDER BY T.PatientId

	 --SELECT  * FROM #PAPPatients

	 IF(OBJECT_ID('tempdb..#RefdatetoTriagetoSP') IS NOT NULL)
		DROP TABLE #RefdatetoTriagetoSP 

	SELECT C.PatientId
		 , MIN(C.CreatedDate) AS CaseCreatedDate
		 , MIN(CSH.CreatedDate) AS TriagedtoSPDate
		 , FORMAT(MIN(C.CreatedDate),'MMM-yyyy') AS DateYYYYMM, FORMAT(MIN(C.CreatedDate),'yyyyMM') AS DateYYYYMMNum
		 , DATEDIFF(DAY,MIN(C.CreatedDate),MIN(CSH.CreatedDate)) AS TAT
		 --, ROW_NUMBER() OVER (PARTITION BY C.PatientId ORDER BY CSH.CreatedDate) AS ShiptmentNo
	  INTO #RefdatetoTriagetoSP
	  FROM dbo.Cases C
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
     INNER JOIN dbo.CaseStatusHistory CSH
	    ON C.Id = CSH.CaseId
	 INNER JOIN dbo.CaseStatus CS
	    ON CSH.CaseStatusId = CS.Id
	 WHERE ET.EnrollmentTypeCode = 'Reimbursement'
	   AND CS.CaseStatusCode IN ('OrderSentToSP')	-- Triaged to SP
	   AND C.CreatedDate BETWEEN @StartDate AND @EndDate
	 GROUP BY C.PatientId
	   
	 IF(OBJECT_ID('tempdb..#TriagetoSPFirstship') IS NOT NULL)
		DROP TABLE #TriagetoSPFirstship

	 SELECT C.PatientId
		 , MIN(CSH.CreatedDate) AS TriagedtoSPDate
		 , MIN(OD.ShipDate) AS FirstShipDate
		 , FORMAT(MIN(CSH.CreatedDate),'MMM-yyyy') AS DateYYYYMM, FORMAT(MIN(CSH.CreatedDate),'yyyyMM') AS DateYYYYMMNum
		 , DATEDIFF(DAY,MIN(CSH.CreatedDate),MIN(OD.ShipDate)) AS TAT
		 --, ROW_NUMBER() OVER (PARTITION BY C.PatientId ORDER BY OD.ShipDate) AS ShiptmentNo
	  INTO #TriagetoSPFirstship
	  FROM dbo.Cases C
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
	 INNER JOIN dbo.CaseStatusHistory CSH
	    ON C.Id = CSH.CaseId
	 INNER JOIN dbo.CaseStatus CS
	    ON CSH.CaseStatusId = CS.Id
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Reimbursement'
	   AND CS.CaseStatusCode IN ('OrderSentToSP')	
	   AND OD.ShipDate IS NOT NULL
	   AND OD.ShipDate >= CAST(CSH.CreatedDate AS DATE)
	   AND CSH.CreatedDate BETWEEN @StartDate AND @EndDate
	 GROUP BY C.PatientId

	IF(OBJECT_ID('tempdb..#BridgeCaseshipment') IS NOT NULL)
		DROP TABLE #BridgeCaseshipment
	SELECT DISTINCT C.PatientId		 
		 , MIN(CSH.CreatedDate) AS [Triaged to Bridge Date]
		 , MIN(OD.ShipDate) AS [1st BridgeShipmentDate]
		 , FORMAT(MIN(CSH.CreatedDate),'MMM-yyyy') AS DateYYYYMM, FORMAT(MIN(OD.ShipDate),'yyyyMM') AS DateYYYYMMNum
		 , DATEDIFF(DAY,MIN(CSH.CreatedDate),MIN(OD.ShipDate)) AS TAT--[Triage to Bridge to 1st shipment (Bridge case)]
	  INTO #BridgeCaseshipment
	  FROM dbo.Cases C	    
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
	 INNER JOIN dbo.CaseStatusHistory CSH
	    ON C.Id = CSH.CaseId
	 INNER JOIN dbo.CaseStatus CS
	    ON CSH.CaseStatusId = CS.Id
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Bridge'
	   AND CS.CaseStatusCode = 'BridgeOrderSentToSP' -- Triaged to Bridge
	   AND OD.ShipDate IS NOT NULL
	   AND OD.ShipDate >= CAST(CSH.CreatedDate AS DATE)
	   AND CSH.CreatedDate BETWEEN @StartDate AND @EndDate
	 GROUP BY C.PatientId
	 
	 SELECT * 
	   FROM
		(
		 SELECT PatientId,DateYYYYMM,DateYYYYMMNum,0 AS TAT,Reason,ISNULL(Payer,'Unknown') AS Payer ,Category,1 AS Section 
			  , CaseCreatedDate StartDate, NULL AS EndDae
		   FROM #PAPPatients
		 UNION
		 SELECT PatientId,DateYYYYMM,DateYYYYMMNum,TAT,'' AS Reason,'' AS Payer, 'Referral received date to triage to SP on Reimbursement case' AS Category,2 AS Section 
			  , CaseCreatedDate, TriagedtoSPDate
		   FROM #RefdatetoTriagetoSP
		 UNION
		 SELECT PatientId,DateYYYYMM,DateYYYYMMNum,TAT,'' AS Reason,'' AS Payer, 'Triage to SP to 1st shipment (reimbursement case) without a bridge shipment' AS Category,2 AS Section
			  , TriagedtoSPDate, FirstShipDate
		  FROM #TriagetoSPFirstship WHERE PatientId NOT IN (SELECT PatientId FROM #BridgeCaseshipment)
		 UNION
		 SELECT PatientId,DateYYYYMM,DateYYYYMMNum,TAT,'' AS Reason,'' AS Payer,'Triage to SP to 1st shipment (reimbursement case) with a bridge shipment' AS Category,2 AS Section 
			  , TriagedtoSPDate, FirstShipDate
		  FROM #TriagetoSPFirstship WHERE PatientId IN (SELECT PatientId FROM #BridgeCaseshipment)
		 UNION
		 SELECT PatientId,DateYYYYMM,DateYYYYMMNum,TAT,'' AS Reason,'' AS Payer,'Triage to Bridge to 1st shipment (Bridge case)' AS Category,2 AS Section 
			  , [Triaged to Bridge Date], [1st BridgeShipmentDate]
		  FROM #BridgeCaseshipment
		) AS T
	ORDER BY Category, T.PatientId,DateYYYYMMNum

END 




 