IF(OBJECT_ID('dbo.usp_rpt_QBR_LengthoftimeontherapyReport') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_LengthoftimeontherapyReport
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_LengthoftimeontherapyReport] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2025-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 1
	EXEC dbo.[usp_rpt_QBR_LengthoftimeontherapyReport] @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON 
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED
        
	/***************************************************************************      
	* Length of time on therapy (January 2025-End of August 2025)
	***************************************************************************/
	IF(OBJECT_ID('tempdb..#Timeontherapy') IS NOT NULL)
		DROP TABLE #Timeontherapy

	SELECT C.Id AS CaseId,C.PatientId, C.CreatedDate AS CaseCreatedDate
		 , FORMAT(C.CreatedDate,'MMM-yyyy') AS DateYYYYMM, FORMAT(C.CreatedDate,'yyyyMM') AS DateYYYYMMNum
		 , CMT.ContactMethodTypeName AS PatientType,OD.ShipDate
		 , ROW_NUMBER() OVER (PARTITION BY CMT.ContactMethodTypeName,C.PatientId ORDER BY OD.ShipDate) AS ShiptmentNo
	  INTO #Timeontherapy
	  FROM dbo.Cases C
	 INNER JOIN dbo.ContactMethodTypes CMT
	    ON C.ContactMethodTypeId = CMT.Id
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Reimbursement'	
	   AND OD.ShipDate IS NOT NULL
	   AND C.CreatedDate BETWEEN @StartDate AND @EndDate
	   --AND CMT.ContactMethodTypeCode = 'DirecttoSP'
	   
	--SELECT * FROM #Timeontherapy

	IF(@debug = 0)
	BEGIN
	SELECT CASE WHEN PatientType = 'Direct to SP' THEN 'Direct to SP' ELSE 'Pathways' END AS PatientType
		 , PatientId,MIN(ShipDate) AS MinShipDate,MAX(ShipDate) AS MaxShipDate
		 , DateYYYYMM,DateYYYYMMNum
		 , DATEDIFF(DAY,MIN(ShipDate),MAX(ShipDate)) AS DaysbetweenShipment
	  FROM #Timeontherapy
	 GROUP BY PatientType,PatientId,DateYYYYMM,DateYYYYMMNum
	END
	 
	IF(@debug = 1)	
	 BEGIN
		SELECT CaseId, PatientId
			 , CaseCreatedDate
			 , DateYYYYMM,DateYYYYMMNum
			 , CASE WHEN PatientType = 'Direct to SP' THEN 'Direct to SP' ELSE 'Pathways' END AS PatientType
			 --, FORMAT(ShipDate,'yyyy-MM-dd' ) AS ShipDate
			 , MIN(ShipDate) AS MinShipDate
			 , MAX(ShipDate) AS MaxShipDate
			 , DATEDIFF(DAY,MIN(ShipDate),MAX(ShipDate)) AS DaysbetweenShipment
		 FROM #Timeontherapy 
		 GROUP BY PatientId,CaseId,DateYYYYMM,DateYYYYMMNum,CaseCreatedDate,PatientType
		 ORDER BY PatientId,CaseID--,ShipDate
	 END
END 
--Length of time on therapy 
--January 2024-end of August 2025 per month
--Compare direct ship (anonymous patients) to Pathways
--Avg time between Date 1st shipment to last shipment (time period) for direct ship vs pathways for each month
--Filter: reimbursement case created in the month


 