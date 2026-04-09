IF(OBJECT_ID('dbo.usp_rpt_QBR_BridgeshipmentsReport') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_BridgeshipmentsReport
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_BridgeshipmentsReport] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2017-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 1
	EXEC dbo.[usp_rpt_QBR_BridgeshipmentsReport] @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED
        
	/***************************************************************************      
	* Bridge shipments (January 2025-End of August 2025)     
	***************************************************************************/
	IF(OBJECT_ID('tempdb..#BridgeCaseshipment') IS NOT NULL)
		DROP TABLE #BridgeCaseshipment
	SELECT C.Id AS CaseId,CON.Id AS HCP,(CON.FirstName +' '+ CON.LastName) AS HCPName ,C.PatientId, C.CreatedDate AS CaseCreatedDate
		 , C.EnrollmentDate, ET.EnrollmentTypeName
		 , OD.ShipDate AS BridgeShipmentDate
		 , FORMAT(C.CreatedDate,'MMM-yyyy') AS DateYYYYMM, FORMAT(C.CreatedDate,'yyyyMM') AS DateYYYYMMNum
		 , ROW_NUMBER() OVER (PARTITION BY C.PatientId ORDER BY C.CreatedDate) AS CaseCreatedNo
	  INTO #BridgeCaseshipment
	  FROM dbo.Cases C
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
	 INNER JOIN dbo.Contacts CON
	    ON CON.Id = C.ContactId
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Bridge'
	   AND OD.ShipDate IS NOT NULL
	   AND C.CreatedDate BETWEEN @StartDate AND @EndDate

	IF(OBJECT_ID('tempdb..#DistinctBridgeCaseshipment') IS NOT NULL)
		DROP TABLE #DistinctBridgeCaseshipment
		
	SELECT HCP,HCPName,PatientId,MIN(DateYYYYMM) AS DateYYYYMM,MIN(DateYYYYMMNum) AS DateYYYYMMNum
		 , MIN(CaseCreatedDate) AS CaseCreatedDate,MIN(BridgeShipmentDate) AS BridgeShipmentDate  
	  INTO #DistinctBridgeCaseshipment
	  FROM #BridgeCaseshipment
	 GROUP BY HCP,HCPName,PatientId--,DateYYYYMM,DateYYYYMMNum

	--SELECT * FROM #DistinctBridgeCaseshipment
	IF(OBJECT_ID('tempdb..#Summary') IS NOT NULL)
		DROP TABLE #Summary

	SELECT  C.PatientId--,BC.HCP,HCPName
		 --,,C.EnrollmentDate, ET.EnrollmentTypeName
		 --, C.ID AS CaseId, OD.ShipDate,BC.BridgeShipmentDate 
		  --, MIN(BC.BridgeShipmentDate) AS BridgeShipmentDate
		  --, MIN(OD.ShipDate) AS ShipDate		  
		  , CASE WHEN MIN(BC.BridgeShipmentDate) < MIN(OD.ShipDate) THEN 1 ELSE 0 END AS [Bridge Shipment Before 1st Reimbursement]
		  , CASE WHEN MIN(BC.BridgeShipmentDate) > MIN(OD.ShipDate) THEN 1 ELSE 0 END AS [Bridge Shipment After 1st Reimbursement]
	  INTO #Summary
	  FROM dbo.Cases C
	 INNER JOIN #DistinctBridgeCaseshipment BC
	    ON C.PatientId = BC.PatientId
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id	 
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Reimbursement'
	   AND OD.ShipDate IS NOT NULL
	   --AND BC.BridgeShipmentDate BETWEEN @StartDate AND @EndDate
	 GROUP BY C.PatientId--, BC.HCP,HCPName
	 --HAVING MIN(BC.BridgeShipmentDate) < MIN(OD.ShipDate)

	IF(@debug = 0)
	BEGIN
		SELECT A.*
			 , B.[Bridge Shipment Before 1st Reimbursement] 
			 , B.[Bridge Shipment After 1st Reimbursement]
		  FROM #DistinctBridgeCaseshipment A
		 INNER JOIN #Summary B
		    ON A.PatientId = B.PatientId
	
	END
	 
	IF(@debug = 1)	
	 BEGIN
		SELECT A.*
			 , B.[Bridge Shipment Before 1st Reimbursement] 
			 , B.[Bridge Shipment After 1st Reimbursement]
		  FROM #DistinctBridgeCaseshipment A
		 INNER JOIN #Summary B
		    ON A.PatientId = B.PatientId
	 END
END 




 