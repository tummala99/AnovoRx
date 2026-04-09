IF (OBJECT_ID('dbo.usp_rpt_Scheduled') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Scheduled
GO

CREATE PROCEDURE dbo.usp_rpt_Scheduled
AS
/*
	Purpose: Generate Schedule Report data
	
	EXEC dbo.usp_rpt_Scheduled
	
*/
BEGIN
	SET NOCOUNT ON

	/*******************************************************
	--------- 010 Precall Format -----------------
	********************************************************/
		IF(OBJECT_ID('tempdb..#010PrecallFormat') IS NOT NULL)
			DROP TABLE #010PrecallFormat

		SELECT [Dispensing ID] AS MRN
			 --,[External ID] AS MRN -- /*******Need clarification the fields as [External ID] is not in the source file and considering [Dispensing ID] AS MRN********/
			 , [Activity Completed Date] AS [Precall Completed Date]
			 , [Arrange ship date with caller Enter ship date] AS [Scheduled Ship Date]
			 , [What days supply of medication does the patient have on hand at this time?] AS DOH
		  INTO #010PrecallFormat
		  FROM dbo.[STG_DaybuePrecallDOH]

		--SELECT   [Dispensing ID],   Max([Activity Completed Date]) AS [MaxOfActivity Completed Date]
		--FROM   dbo.[STG_DaybuePrecallDOH]
		--GROUP BY   [Dispensing ID];

		  --SELECT MRN,MAX([Precall Completed Date]) AS [MaxOfActivity Completed Date]
		  --  FROM  #010PrecallFormat
		  -- GROUP BY MRN
	

		/*******************************************************
		--------- 012 Precall -----------------
		********************************************************/
		IF(OBJECT_ID('tempdb..#012Precall') IS NOT NULL)
		DROP TABLE #012Precall

		SELECT A.MRN
			 , CAST(MaxOfActivity.[MaxOfActivity Completed Date] AS DATE) AS [MaxOfActivity Completed Date]
			 , CAST(A.[Scheduled Ship Date] AS DATE) AS [Scheduled Ship Date]
			 , A.DOH
			 , [DOH] + ' DOH on ' + [Precall Completed Date] + ' shipping ' + [scheduled Ship Date] AS [DOH Ship Date]
			 , DATEADD(DAY,CAST([doh] AS INT),CAST([Precall completed date] AS DATE)) AS [Actual doh]
		  INTO #012Precall
		  FROM #010PrecallFormat A
		 INNER JOIN ( SELECT MRN,MAX([Precall Completed Date]) AS [MaxOfActivity Completed Date]
		  FROM  #010PrecallFormat
		 GROUP BY MRN) AS MaxOfActivity
		    ON CAST(A.[Precall Completed Date] AS DATE) = CAST(MaxOfActivity.[MaxOfActivity Completed Date] AS DATE)
		   AND A.MRN = MaxOfActivity.[MRN]
		 WHERE A.[Scheduled Ship Date] IS NOT NULL;

	/*******************************************************
	--------- 601 Max Claims -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#601MaxClaims') IS NOT NULL)
		DROP TABLE #601MaxClaims

	SELECT note_patient_mrn
		 , MAX(note_sys_id) AS MaxOfnote_sys_id
	  INTO #601MaxClaims
	  FROM dbo.[STG_DaybuePayable]	
	 GROUP BY note_patient_mrn;
	
	/*******************************************************
	--------- 602 Claims -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#602Claims') IS NOT NULL)
		DROP TABLE #602Claims

	SELECT A.patient_full_name
		 , A.note_patient_mrn
		 , A.note_entered_date
		 , A.note_subject
		 , A.note_body
	  INTO #602Claims
	  FROM dbo.[STG_DaybuePayable] A
	 INNER JOIN #601MaxClaims B 
	    ON A.note_patient_mrn = B.note_patient_mrn
	   AND A.note_sys_id = B.MaxOfnote_sys_id
	/************************************************
	************_600_Scheduled*******************
	*************************************************/
	IF(OBJECT_ID('dbo.rpt_600_Scheduled') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_600_Scheduled
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_600_Scheduled (ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT ,[Queue] VARCHAR(255),Payer VARCHAR(255) 
				, [Secondary] VARCHAR(255),[Last Fill] DATE,Scheduled DATE,[Last Event Date] DATE
				, [Need by Date] DATE,[Precall Completed On] DATE,DOH INT, [Exhaust Per Therigy] DATE, [DOH On Ship Date] INT,Notes VARCHAR(4000)
			)
	END
	
	INSERT INTO dbo.rpt_600_Scheduled ([Name] , [MRN] , [HUB ID],[Queue] ,Payer  
				 , [Secondary]  ,[Last Fill] ,Scheduled ,[Need by Date],[Precall Completed On]
				 , DOH  ,[Exhaust Per Therigy] ,[DOH On Ship Date],Notes
			)	
	SELECT A.[Name]
		 , A.mrn AS MRN
		 , A.[HUB ID]
		 , A.[Queue]
		 , A.Payer
		 , A.[Secondary]
		 , A.[Last Fill]
		 , A.[Next Fill] AS Scheduled
		 , A.[Need by Date]
		 , B.[MaxofActivity Completed Date] AS [Precall Completed On]
		 , B.DOH
		 , B.[Actual doh] AS [Exhaust Per Therigy]
		 , DATEDIFF(DAY, [Scheduled Ship Date], [Actual DOH]) AS [DOH On Ship Date]
		 , C.note_body AS Notes
	  FROM  dbo.rpt_100_Dashboard_Review A
	  LEFT JOIN #012Precall B
	    ON A.MRN = B.MRN    
	  LEFT JOIN #602Claims C 
	    ON A.MRN = C.note_patient_mrn
	 WHERE (A.[Queue] LIKE 'C%'
			OR (A.[Queue]) LIKE 'E%'
			OR (A.[Queue]) LIKE 'D%'	
			)
	ORDER BY A.[Next Fill];
	
END
       
	   