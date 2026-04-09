USE CT1UAT
IF(OBJECT_ID('dbo.usp_rpt_QBR_PriorAuthorizations') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_QBR_PriorAuthorizations
GO

CREATE PROCEDURE [dbo].[usp_rpt_QBR_PriorAuthorizations] (@StartDate DATETIME ='2025-01-01',@EndDate DATETIME ='2025-08-31',@debug INT = 0)                 
AS                         
/*        
	DECLARE @StartDate DATE,@EndDate DATE,@debug INT
	SET @StartDate = '2025-01-01'
	SET @EndDate = '2025-08-31'         
	SET @debug = 2
	EXEC dbo.[usp_rpt_QBR_PriorAuthorizations] @StartDate,@EndDate,@debug
*/             
BEGIN      
	SET NOCOUNT ON
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED 
	--DECLARE @StartDate DATE,@EndDate DATE
	--SET @StartDate = '2025-01-01'
	--SET @EndDate = '2025-08-31'
	/***************************************************************************      
	* Prior authorizations     
	***************************************************************************/
	IF(OBJECT_ID('tempdb..#PACounts') IS NOT NULL)
		DROP TABLE #PACounts

	SELECT PatientId,CaseId,CaseStatusDate,CaseStatusName,CaseStatusCode
		 , SubStatus
		 , DateYYYYMM,DateYYYYMMNum
	  INTO #PACounts
	  FROM 
		(
		SELECT C.PatientId,C.Id AS CaseId,CSH.CreatedDate AS CaseStatusDate, CS.CaseStatusName,CS.CaseStatusCode
			 , CAT.CategoryName AS SubStatus
			 , FORMAT(CSH.CreatedDate,'MMM-yyyy') AS DateYYYYMM
			 , FORMAT(CSH.CreatedDate,'yyyyMM') AS DateYYYYMMNum
			 , ROW_NUMBER() OVER (PARTITION BY C.PatientId,C.Id,CS.CaseStatusName ORDER BY CSH.CreatedDate ASC) AS RowId
		  FROM dbo.Cases C	    
		 --INNER JOIN dbo.EnrollmentTypes ET
		 --   ON C.EnrollmentTypeId = ET.Id
		 INNER JOIN dbo.CaseStatusHistory CSH
			ON C.Id = CSH.CaseId
		 INNER JOIN dbo.CaseStates CST
			ON C.CaseStateId = CST.Id
		 INNER JOIN dbo.CaseStatus CS
			ON CSH.CaseStatusId = CS.Id	  
		  LEFT JOIN dbo.Categories CAT
		    ON CSH.CaseSubstatusId = CAT.Id	  
		 WHERE 1 = 1 --ET.EnrollmentTypeCode = 'Reimbursement'
		   AND CS.CaseStatusCode IN ('BVCompleted','PAInprocess','PAApproved','PADenied','Appeal1stLevelInprocess','Appeal1stLevelApproved','Appeal1stLevelDenied')
		   AND CSH.CreatedDate BETWEEN @StartDate AND @EndDate
		--ORDER BY C.PatientId,C.Id,CSH.CreatedDate
		) AS T
	 WHERE T.RowId = 1
	 ORDER BY PatientId,CaseId,CaseStatusDate
	/*****************************************************/
	IF(OBJECT_ID('tempdb..#PASummary') IS NOT NULL)
		DROP TABLE #PASummary	 

	SELECT CAST(COUNT(CaseId) AS FLOAT) AS CaseCount,CaseStatusCode,DateYYYYMM,DateYYYYMMNum
	  INTO #PASummary	
	  FROM #PACounts 
	 WHERE CaseStatusCode IN ('PAInprocess','PAApproved','PADenied','Appeal1stLevelInprocess','Appeal1stLevelApproved','Appeal1stLevelDenied')
	 GROUP BY CaseStatusCode,DateYYYYMM,DateYYYYMMNum

	/*****************************Get all the Cases which are in PA Inprocess and 1st levelAppeal inprocess till date******************************/

	IF(OBJECT_ID('tempdb..#PACases') IS NOT NULL)
		DROP TABLE #PACases

	SELECT DISTINCT C.PatientID,C.Id AS CaseId, CS.CaseStatusName,CS.CaseStatusCode	
		 --, CSH.CreatedDate
	--, FORMAT(CSH.CreatedDate,'MMM-yyyy') AS DateYYYYMM
		 , FORMAT(MAX(CSH.CreatedDate),'yyyyMM') AS DateYYYYMMNum
	--, ROW_NUMBER() OVER (PARTITION BY C.PatientId,C.Id,CS.CaseStatusName ORDER BY CSH.CreatedDate ASC) AS RowId
	  INTO #PACases	
	  FROM dbo.Cases C	    
	--INNER JOIN dbo.EnrollmentTypes ET
	--   ON C.EnrollmentTypeId = ET.Id
	 INNER JOIN dbo.CaseStatusHistory CSH
	    ON C.Id = CSH.CaseId
	 INNER JOIN dbo.CaseStates CST
		ON C.CaseStateId = CST.Id
	 INNER JOIN dbo.CaseStatus CS
		ON CSH.CaseStatusId = CS.Id	  
	  LEFT JOIN dbo.Categories CAT
		ON CSH.CaseSubstatusId = CAT.Id	  
	 WHERE 1 = 1 --ET.EnrollmentTypeCode = 'Reimbursement'
	   AND CS.CaseStatusCode IN ('PAInprocess','Appeal1stLevelInprocess','Appeal1stLevelInprocess','PAApproved','Appeal1stLevelApproved')		   
	 GROUP BY C.PatientID,C.Id,CS.CaseStatusName,CS.CaseStatusCode
	 ORDER BY C.PatientId,C.Id,CS.CaseStatusCode--,CSH.CreatedDate -- 30001

	 --SELECT * FROM #InprocessCases WHERE CaseStatusCode = 'PAInprocess' AND DateYYYYMMNum < 202501
	/**********************% of prior authorizations approved *******************************/

	IF(OBJECT_ID('tempdb..#PAInprocessCases') IS NOT NULL)
		DROP TABLE #PAInprocessCases

	 SELECT DISTINCT A.PatientId
		  , A.CaseId, A.CaseStatusCode, A.DateYYYYMMNum
		  , B.DateYYYYMMNum AS PAApprovedDate
	   INTO #PAInprocessCases		  
	   FROM #PACases A
	   LEFT JOIN #PACases B
	     ON A.PatientId = B.PatientId
	    AND A.CaseId = B.CaseId
		AND B.CaseStatusCode = 'PAApproved'
	  WHERE A.CaseStatusCode = 'PAInprocess'
	    --AND B.CaseId IS NULL -- 299
	 ORDER BY A.PatientId,A.CaseId -- 1392

	--SELECT * FROM #PACounts WHERE CaseStatusCode IN ('PAInprocess','PAApproved')

	IF(OBJECT_ID('tempdb..#PAApprovePer') IS NOT NULL)
		DROP TABLE #PAApprovePer

	;WITH PAApproved
		AS(
		SELECT COUNT(CaseId) AS CaseCount,DateYYYYMM,DateYYYYMMNum
		  FROM #PACounts WHERE CaseStatusCode IN ('PAApproved')
		 GROUP BY DateYYYYMM,DateYYYYMMNum
		)

	SELECT ((A.CaseCount*1.0/NULLIF(T.PAInprocessCount,0)) * 100) AS Perc
		 , A.CaseCount,T.PAInprocessCount
		 , '%PAApproved' AS CaseStatusCode
	     , A.DateYYYYMM
		 , A.DateYYYYMMNum
	  INTO #PAApprovePer		 
	  FROM PAApproved A
	  OUTER APPLY (
					SELECT COUNT(DISTINCT CaseId) AS 'PAInprocessCount'
					  FROM #PAInprocessCases 
					 WHERE CaseStatusCode = 'PAInprocess' 
					   AND DateYYYYMMNum < A.DateYYYYMMNum 
					   AND (PAApprovedDate > A.DateYYYYMMNum OR PAApprovedDate IS NULL)
				) AS T

	INSERT INTO #PASummary (CaseCount,CaseStatusCode,DateYYYYMM,DateYYYYMMNum)
	SELECT Perc,CaseStatusCode,DateYYYYMM,DateYYYYMMNum FROM #PAApprovePer	
 
 
	/**********************% of patients approved with 1st level appeal*******************************/
	IF(OBJECT_ID('tempdb..#AppealInprocessCases') IS NOT NULL)
		DROP TABLE #AppealInprocessCases

	 SELECT DISTINCT A.PatientId
		  , A.CaseId, A.CaseStatusCode, A.DateYYYYMMNum
		  , B.DateYYYYMMNum AS PAApprovedDate
	   INTO #AppealInprocessCases		  
	   FROM #PACases A
	   LEFT JOIN #PACases B
	     ON A.PatientId = B.PatientId
	    AND A.CaseId = B.CaseId
		AND B.CaseStatusCode = 'Appeal1stLevelApproved'
	  WHERE A.CaseStatusCode = 'Appeal1stLevelInprocess'
	    --AND B.CaseId IS NULL -- 299
	 ORDER BY A.PatientId,A.CaseId -- 1392

	 IF(OBJECT_ID('tempdb..#Appeal1stApprovePer') IS NOT NULL)
		DROP TABLE #Appeal1stApprovePer

	;WITH Appeal1stLevelApproved
		AS(
		SELECT COUNT(CaseId) AS CaseCount,DateYYYYMM,DateYYYYMMNum
		  FROM #PACounts WHERE CaseStatusCode IN ('Appeal1stLevelApproved')
		 GROUP BY DateYYYYMM,DateYYYYMMNum
		)

	SELECT ((A.CaseCount*1.0/NULLIF(T.AppealInprocessCount,0)) * 100) AS Perc
		 , A.CaseCount,T.AppealInprocessCount
		 , '%firstlevelappealApproved' AS CaseStatusCode
	     , A.DateYYYYMM
		 , A.DateYYYYMMNum
	  INTO #Appeal1stApprovePer		 
	  FROM Appeal1stLevelApproved A
	  OUTER APPLY (
					SELECT COUNT(DISTINCT CaseId) AS 'AppealInprocessCount'
					  FROM #AppealInprocessCases 
					 WHERE CaseStatusCode = 'Appeal1stLevelInprocess' 
					   AND DateYYYYMMNum < A.DateYYYYMMNum 
					   AND (PAApprovedDate > A.DateYYYYMMNum OR PAApprovedDate IS NULL)
				) AS T

	INSERT INTO #PASummary (CaseCount,CaseStatusCode,DateYYYYMM,DateYYYYMMNum)
	SELECT Perc,CaseStatusCode,DateYYYYMM,DateYYYYMMNum FROM #Appeal1stApprovePer

	 /*********************% of patients approved with 2nd level of appeal********************************/

	-- IF(OBJECT_ID('tempdb..#Appeal2ndApprovePer') IS NOT NULL)
	--	DROP TABLE #Appeal2ndApprovePer

	--;WITH Appeal2stLevelApproved
	--	AS(
	--	SELECT COUNT(CaseId) AS CaseCount,DateYYYYMM,DateYYYYMMNum
	--	  FROM #PACounts WHERE CaseStatusCode IN ('BVCompleted','PAApproved','Appeal1stLevelApproved')
	--	 GROUP BY DateYYYYMM,DateYYYYMMNum
	--	),
	--	Appeal2stLevelInprocess
	--	AS
	--	(
	--	SELECT * FROM #InprocessCases WHERE CaseStatusCode IN ('Appeal2stLevelInprocess')
	--		--SELECT DateYYYYMMNum,CaseCount,			
	--		--	SUM(CaseCount) OVER (
	--		--		ORDER BY DateYYYYMMNum
	--		--		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	--		--	) AS CumulativeCaseCount
	--		--FROM #InprocessCases
	--		--WHERE CaseStatusCode IN ('Appeal2ndLevelApproved')
	--	)
	

	--SELECT ((MIN(A.CaseCount)*1.0/NULLIF(SUM(B.CaseCount),0)) * 100) AS Perc
	--	 , '%SecondlevelappealApproved' AS CaseStatusCode
	--     , A.DateYYYYMM
	--	 , A.DateYYYYMMNum		 
	--  INTO #Appeal2ndApprovePer
	--  FROM Appeal2stLevelApproved A	  
	--  LEFT JOIN Appeal2stLevelInprocess B
	--    ON A.DateYYYYMMNum > B.DateYYYYMMNum
	-- GROUP BY A.DateYYYYMMNum,A.DateYYYYMM
	-- ORDER BY A.DateYYYYMMNum,A.DateYYYYMM

	--INSERT INTO #PASummary (CaseCount,CaseStatusCode,DateYYYYMM,DateYYYYMMNum)
	--SELECT Perc,CaseStatusCode,DateYYYYMM,DateYYYYMMNum FROM #Appeal2ndApprovePer
	
	--------------------------------------------------------------------------------

	 IF(OBJECT_ID('tempdb..#List') IS NOT NULL)
		DROP TABLE #List

	SELECT * 
	 INTO #List
	 FROM 
		(
		 SELECT 'PAInprocess' AS CaseStatusCode,'# of prior authorization started per month' AS DisplayName, 1 AS OrderNo
		 UNION
		 SELECT 'PAApproved' AS CaseStatusCode,'# of prior authorization approval per month' AS DisplayName, 2 AS OrderNo
		 UNION
		 SELECT 'PADenied' AS CaseStatusCode,'# of prior authorizations denied then appeal?' AS DisplayName, 3 AS OrderNo
		 UNION
		 SELECT 'Appeal1stLevelInprocess' AS CaseStatusCode,'# 1st appeal started' AS DisplayName, 4 AS OrderNo
		 UNION
		 SELECT 'Appeal1stLevelApproved' AS CaseStatusCode,'# 1st appeal  approved' AS DisplayName, 5 AS OrderNo
		 UNION
		 SELECT 'Appeal1stLevelDenied' AS CaseStatusCode,'# 1st appeal Denied' AS DisplayName, 6 AS OrderNo
		 --UNION
		 --SELECT 'PAInprocess' AS CaseStatusCode,'# 2st appeal started' AS DisplayName, 7 AS OrderNo
		 --UNION
		 --SELECT 'PAInprocess' AS CaseStatusCode,'# 2st appeal  approved' AS DisplayName, 8 AS OrderNo
		 --UNION
		 --SELECT 'PAInprocess' AS CaseStatusCode,'# 2st appeal Denied' AS DisplayName, 9 AS OrderNo
		 UNION
		 SELECT '%PAApproved' AS CaseStatusCode,'% of prior authorizations approved' AS DisplayName, 10 AS OrderNo
		 UNION
		 SELECT '%firstlevelappealApproved' AS CaseStatusCode,'% of patients approved with first level appeal' AS DisplayName, 11 AS OrderNo
		 --UNION
		 --SELECT '%SecondlevelappealApproved' AS CaseStatusCode,'% of patients approved with second level of appeal' AS DisplayName, 12 AS OrderNo
		) AS T

	IF(@debug = 0)
	BEGIN
		SELECT A.DisplayName,ROUND(B.CaseCount,2) AS CaseCount --,CaseStatusDate,CaseStatusName--,B.DateYYYYMM,B.DateYYYYMMNum
			 --, B.SubStatus
			 , ISNULL(B.DateYYYYMM,'Jan-2025') AS DateYYYYMM 
			 , ISNULL(B.DateYYYYMMNum,202501) AS DateYYYYMMNum
			 , A.OrderNo
		  FROM #List A
		  LEFT JOIN #PASummary B
			ON A.CaseStatusCode = B.CaseStatusCode
		 ORDER BY A.OrderNo,DateYYYYMMNum
	END
	ELSE IF(@debug = 1)
	BEGIN
		
		SELECT A.DisplayName,B.DateYYYYMM,B.DateYYYYMMNum
			 , B.PatientId,B.CaseId,B.CaseStatusName,B.CaseStatusDate,A.OrderNo 
		  FROM #List A
		 INNER JOIN #PACounts B
		    ON A.CaseStatusCode = B.CaseStatusCode	    
		 ORDER BY A.OrderNo,DateYYYYMM,DateYYYYMMNum,B.PatientId,B.CaseId
		 --SELECT * FROM #PACounts76,26
		 --SELECT * FROM #PASummary
	END
	ELSE IF(@debug = 2)
	BEGIN
		SELECT A.DisplayName
			 , B.DateYYYYMM
			 , B.CaseCount AS ApprovedCaseCount 
			 , B.PAInprocessCount AS InprocessCaseCount
			 , ROUND(((B.CaseCount * 1.0/NULLIF(B.PAInprocessCount,0)) * 100),2) AS [% OF Approved Cases]
			 ,A.OrderNo,B.DateYYYYMMNum
		  FROM #List A
		 INNER JOIN
			(
			SELECT * FROM #PAApprovePer
			UNION
			SELECT * FROM #Appeal1stApprovePer
			) AS B
		   ON A.CaseStatusCode = B.CaseStatusCode
		ORDER BY A.OrderNo,B.DateYYYYMMNum
	END
END
