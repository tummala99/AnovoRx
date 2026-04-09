IF (OBJECT_ID('dbo.usp_rpt_Days_to_Exhaust') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Days_to_Exhaust
GO

CREATE PROCEDURE dbo.usp_rpt_Days_to_Exhaust
AS
/*
	Purpose: Generate Days to Exhaust Report data
	
	EXEC dbo.usp_rpt_Days_to_Exhaust
	
*/
BEGIN
	SET NOCOUNT ON

	/*******************************************************
	--------- 401 Max Attempt -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#401MaxAttempt') IS NOT NULL)
		DROP TABLE #401MaxAttempt

	SELECT MRN
		 , MAX(note_sys_id) AS MaxOfnote_sys_id
	  INTO #401MaxAttempt
	  FROM dbo.[STG_DaybueAttempttoContact]
	 GROUP BY MRN;
	
	/*******************************************************
	--------- 402 Attempt to Contact -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#402AttempttoContact') IS NOT NULL)
		DROP TABLE #402AttempttoContact

	SELECT B.MRN
		 , B.[Date]
		 , B.[Subject]
		 , B.Note
		 , CASE WHEN [Note] LIKE '%Yes%' THEN 'LVM on ' + [Date]
				ELSE 'Unable to LVM on ' + [Date]
		   END AS Attempt	
	  INTO #402AttempttoContact		   
	  FROM #401MaxAttempt A
	 INNER JOIN dbo.[STG_DaybueAttempttoContact] B 
	    ON A.MaxOfnote_sys_id = B.note_sys_id
	   AND A.MRN = B.MRN
	/*******************************************************
	--------- 403 Max Date Communication Notes -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#403MaxDateCommunicationNotes') IS NOT NULL)
		DROP TABLE #403MaxDateCommunicationNotes
	SELECT MRN
		 , MAX(note_sys_id) AS MaxOfnote_sys_id
	  INTO #403MaxDateCommunicationNotes
	  FROM dbo.[STG_DaybueCommunicationNotes]
	 GROUP BY MRN;
	/*******************************************************
	--------- 404 Communication Notes -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#404CommunicationNotes') IS NOT NULL)
		DROP TABLE #404CommunicationNotes

	SELECT A.MRN
		 , A.[Date]
		 , A.[Subject]
		 , A.[Date] + A.[Note] AS [Note]
	  INTO #404CommunicationNotes
	  FROM dbo.[STG_DaybueCommunicationNotes] A
	 INNER JOIN #403MaxDateCommunicationNotes B 
	    ON A.note_sys_id = B.MaxOfnote_sys_id
	   AND A.MRN = B.MRN
	/************************************************
	************_400_Days_to_Exhaust*******************
	*************************************************/
	IF(OBJECT_ID('dbo.rpt_400_Days_to_Exhaust') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_400_Days_to_Exhaust
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_400_Days_to_Exhaust(ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT,[Queue] VARCHAR(255),[Last Event] VARCHAR(255),[Last Event Date] DATE,[Last Fill] DATE
				, [Next Fill] DATE,[Need by Date] DATE,Category VARCHAR(255),[Review Notes] VARCHAR(4000),Attempt VARCHAR(4000)
			)
	END

	INSERT INTO dbo.rpt_400_Days_to_Exhaust([Name] , [MRN] , [HUB ID] ,[Queue] ,[Last Event] ,[Last Event Date] ,[Last Fill]
				 , [Next Fill] ,[Need by Date] ,Category ,[Review Notes],Attempt)
	SELECT A.[Name]
		 , A.MRN
		 , A.[HUB ID]
		 , A.[Queue]
		 , A.[Last Event]
		 , A.[Last Event Date]
		 , A.[Last Fill]
		 , A.[Next Fill]
		 , A.[Need by Date]
		 , A.Category
		 , CASE WHEN A.[Review Notes] IS NOT NULL THEN A.[Review Notes]
				ELSE C.[Note]
		   END AS [Review Notes] 			 
		 , B.Attempt
	FROM dbo.rpt_100_Dashboard_Review A	
	LEFT JOIN #402AttempttoContact B 
	ON A.MRN = B.MRN	
	LEFT JOIN #404CommunicationNotes C 
	ON A.MRN = C.MRN
	WHERE A.Category = '<7 Days to Exhaust'
	
END
       