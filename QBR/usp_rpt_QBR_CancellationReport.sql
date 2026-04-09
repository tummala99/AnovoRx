IF(OBJECT_ID('dbo.usp_rpt_QBR_CancellationReport') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_CancellationReport
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_CancellationReport] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2025-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 1
	EXEC dbo.usp_rpt_QBR_CancellationReport @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON 
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED
        
	/***************************************************************************      
	* Cancellation (January 2025-End of August 2025)      
	***************************************************************************/
	IF(OBJECT_ID('tempdb..#CancelledCases') IS NOT NULL)
		DROP TABLE #CancelledCases

	SELECT C.Id AS CaseID,C.PatientID,C.CreatedDate AS [Date of referral] ,C.CaseStatusModifiedDate AS [Case Cancellation Date]
		 , CS.CaseStatusName AS [CASE Status],ISNULL(CAT.CategoryName,'Unknown') AS [Reson for Cancellation] 
	  INTO #CancelledCases
	  FROM dbo.Cases C
	 INNER JOIN dbo.CaseStates CST
	    ON C.CaseStateId = CST.Id
	 INNER JOIN dbo.CaseStatus CS
	    ON C.CaseStatusId = CS.Id
	 INNER JOIN dbo.EnrollmentTypes ET
	    ON C.EnrollmentTypeId = ET.Id
	  LEFT JOIN dbo.Categories CAT
	    ON C.OtherCaseState = CAT.Id
	 WHERE CST.CaseStateCode = 'Close'
	   AND CS.CaseStatusCode = 'Cancelled'
	   AND ET.EnrollmentTypeCode = 'Reimbursement'
	   AND C.CreatedDate BETWEEN @StartDate AND @EndDate
	 ORDER BY C.Id

	IF(@debug = 0)
	BEGIN
	SELECT CaseID,PatientId,FORMAT([Date of referral],'MMM-yyyy') AS DateYYYYMM
		 , FORMAT([Date of referral],'yyyyMM') AS DateYYYYMMNum
		 , DATEDIFF(DAY,[Date of referral],[Case Cancellation Date]) AS TAT 
		 , [Reson for Cancellation]
	  FROM #CancelledCases
	END
	 
	IF(@debug = 1)	
	 BEGIN
		SELECT CaseId, PatientId
			 , [Date of referral]
			 , [Case Cancellation Date]
			 , [CASE Status],[Reson for Cancellation]
		 FROM #CancelledCases ORDER BY PatientId,CaseID,[Date of referral]
	 END
END 




 