IF(OBJECT_ID('dbo.usp_rpt_QBR_FirstReimbursementshipmentReport') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_FirstReimbursementshipmentReport
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_FirstReimbursementshipmentReport] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2025-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 1
	EXEC dbo.[usp_rpt_QBR_FirstReimbursementshipmentReport] @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON 
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED
        
	/***************************************************************************      
	* Date of referral to 1st Reimbursement shipment (January 2025-End of August 2025)     
	***************************************************************************/
	IF(OBJECT_ID('tempdb..#FirstShipment') IS NOT NULL)
		DROP TABLE #FirstShipment

	SELECT C.Id AS CaseId,C.PatientId,C.CreatedDate AS CaseCreatedDate,OD.ShipDate
		 , FORMAT(C.CreatedDate,'MMM-yyyy') AS DateYYYYMM, FORMAT(C.CreatedDate,'yyyyMM') AS DateYYYYMMNum
		 , ROW_NUMBER() OVER (PARTITION BY C.PatientId ORDER BY OD.ShipDate) AS ShiptmentNo
	  INTO #FirstShipment
	  FROM dbo.Cases C
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
     INNER JOIN dbo.DTOrders O
	    ON C.Id = O.CaseId
	 INNER JOIN dbo.DTOrderDetails OD
	    ON O.Id = OD.DTOrderId
	 WHERE ET.EnrollmentTypeCode = 'Reimbursement'
	   AND OD.ShipDate IS NOT NULL
	   AND C.CreatedDate BETWEEN @StartDate AND @EndDate
	   
	--SELECT * FROM #FirstShipment WHERE ShiptmentNo = 1

	IF(@debug = 0)
	BEGIN
	SELECT PatientId,MIN(CaseCreatedDate) AS CaseCreatedDate,MIN(ShipDate) AS FirstShipDate
		 , MIN(DateYYYYMM) AS DateYYYYMM,MIN(DateYYYYMMNum) AS DateYYYYMMNum
		 , DATEDIFF(DAY,MIN(CaseCreatedDate),MIN(ShipDate)) AS TAT
	  FROM #FirstShipment
	 GROUP BY PatientId
	END
	 
	IF(@debug = 1)	
	 BEGIN
		SELECT PatientId,CaseId
			 , CaseCreatedDate
			 , ShipDate AS FirstShipDate
			 , DateYYYYMM			 
			 , FORMAT(ShipDate,'yyyy-MM-dd' ) AS ShipDate
		 FROM #FirstShipment 
		WHERE ShiptmentNo = 1
		ORDER BY PatientId,CaseID,ShipDate
	 END
END 
--Date of referral to 1st Reimbursement shipment
--January 2025-end of August 2025 per month
--How many patients and avg turn around time per month 
--Reimbursement Created Date and 1 st shipment date of each patient (Average per month)



 