IF (OBJECT_ID('dbo.usp_rpt_No_Go') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_No_Go
GO

CREATE PROCEDURE dbo.usp_rpt_No_Go
AS
/*
	Purpose: Generate Days to Exhaust Report data
	
	EXEC dbo.usp_rpt_No_Go
	
*/
BEGIN
	SET NOCOUNT ON

	/*******************************************************
	--------- 501 No Go Entered Max -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#501NoGoEnteredMax') IS NOT NULL)
		DROP TABLE #501NoGoEnteredMax

	SELECT note_patient_mrn AS MRN
		 , MAX(note_entered_date) AS MaxOfnote_entered_date
		 , note_subject
	  INTO #501NoGoEnteredMax
	  FROM dbo.[STG_DaybueNoGo]
	 WHERE note_subject != 'No Go- Resolution'
	 GROUP BY note_patient_mrn,	note_subject
	--HAVING note_subject <> 'No Go- Resolution'
	
	
	/*******************************************************
	--------- 502 No Go Entered -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#502NoGoEntered') IS NOT NULL)
		DROP TABLE #502NoGoEntered

	SELECT A.patient_full_name
		 , B.MRN
		 , A.patient_service_area AS [HUB ID]
		 , B.MaxOfnote_entered_date
		 , B.note_subject
		 , A.note_body
	  INTO #502NoGoEntered
	  FROM dbo.[STG_DaybueNoGo] A
	 INNER JOIN #501NoGoEnteredMax B 
	    ON CAST(A.note_entered_date AS DATE) = CAST(B.MaxOfnote_entered_date AS DATE)
	   AND A.note_subject = B.note_subject
	   AND A.note_patient_mrn = B.MRN	  

	/*******************************************************
	--------- 503 Max Date No Go Resolved -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#503MaxDateNoGoResolved') IS NOT NULL)
		DROP TABLE #503MaxDateNoGoResolved

	SELECT note_patient_mrn AS MRN
		 , MAX(note_entered_date) AS MaxOfnote_entered_date
		 , note_subject
	  INTO #503MaxDateNoGoResolved
	  FROM dbo.[STG_DaybueNoGo]
	 WHERE note_subject = 'No Go- Resolution'
	 GROUP BY note_patient_mrn, note_subject
	--HAVING note_subject = 'No Go- Resolution'
	
	/*******************************************************
	--------- 504 No Go Resolved -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#504NoGoResolved') IS NOT NULL)
		DROP TABLE #504NoGoResolved

	SELECT A.MRN
		 , A.MaxOfnote_entered_date
		 , A.note_subject
		 , B.note_body
	  INTO #504NoGoResolved
	  FROM #503MaxDateNoGoResolved A
	 INNER JOIN dbo.[STG_DaybueNoGo] B 
	    ON A.note_subject = B.note_subject
	   AND CAST(A.MaxOfnote_entered_date AS DATE) = CAST(B.note_entered_date AS DATE)
	   AND A.MRN = B.note_patient_mrn
	/************************************************
	************_500_No_Go*******************
	*************************************************/
	IF(OBJECT_ID('dbo.rpt_500_No_Go') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_500_No_Go
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_500_No_Go(ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT,Payer VARCHAR(255),[No Go Date] DATE,[Subject] VARCHAR(255),
				[No Go Note] VARCHAR(4000),[Resolved Date] DATE,Resolved VARCHAR(255),[Resolved Note] VARCHAR(4000)
			)
	END
	
	INSERT INTO dbo.rpt_500_No_Go([Name] , [MRN] , [HUB ID] ,Payer ,[No Go Date] ,[Subject] ,[No Go Note]
				 , [Resolved Date] ,Resolved ,[Resolved Note])
	SELECT DISTINCT A.patient_full_name AS [Name]
		 , A.MRN
		 , A.[HUB ID]
		 , C.Payer
		 , A.MaxOfnote_entered_date AS [No Go Date]
		 , A.note_subject AS [Subject]
		 , A.note_body AS [No Go Note]
		 , B.MaxOfnote_entered_date AS [Resolved Date]
		 , B.note_subject AS Resolved
		 , IIF( B.[note_body] IS NOT NULL,B.[note_body],[Follow Up Notes]) AS [Resolved Note]
	  FROM #502NoGoEntered A
	  LEFT JOIN #504NoGoResolved B 
	    ON A.MRN = B.MRN	
	  LEFT JOIN dbo.rpt_100_Dashboard_Review C 
	    ON A.MRN = C.MRN	
	  LEFT JOIN dbo.[STG_Afternoon_Review] D 
	    ON A.MRN = D.MRN
	 ORDER BY A.MaxOfnote_entered_date DESC;
	
END
       
	   