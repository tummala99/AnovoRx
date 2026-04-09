IF (OBJECT_ID('dbo.usp_rpt_Early_Shipment') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Early_Shipment
GO

CREATE PROCEDURE dbo.usp_rpt_Early_Shipment
AS
/*
	Purpose: Generate Early Shipment Report data
	
	EXEC dbo.usp_rpt_Early_Shipment
	
*/
BEGIN
	SET NOCOUNT ON

	/*******************************************************
	--------- 301 Max Test Claims -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#301MaxTestClaims') IS NOT NULL)
		DROP TABLE #301MaxTestClaims

	SELECT note_patient_mrn
		 , MAX(note_sys_id) AS MaxOfnote_sys_id
      INTO #301MaxTestClaims
	  FROM dbo.[STG_DaybueTestClaims]		
	 GROUP BY note_patient_mrn;
	
	/*******************************************************
	--------- 302 Test Claims -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#302TestClaims') IS NOT NULL)
		DROP TABLE #302TestClaims

	SELECT A.patient_full_name
		 , A.note_patient_mrn
		 , A.note_entered_date
		 , A.note_subject
		 , A.note_body
		 , A.note_sys_id
	  INTO #302TestClaims
	  FROM dbo.[STG_DaybueTestClaims] A
	 INNER JOIN #301MaxTestClaims B 
	    ON A.note_sys_id = B.MaxOfnote_sys_id	
	   AND A.note_patient_mrn = B.note_patient_mrn

	/************************************************
	************_300_Early_Shipment*******************
	*************************************************/
	IF(OBJECT_ID('dbo.rpt_300_Early_Shipment') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_300_Early_Shipment
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_300_Early_Shipment(ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT,[Queue] VARCHAR(255),[Last Event] VARCHAR(255),[Last Event Date] DATE,[Last Fill] DATE
				, [Next Fill] DATE,[Need by Date] DATE,Category VARCHAR(255),[Review Notes] VARCHAR(4000)
			)
	END

	INSERT INTO dbo.rpt_300_Early_Shipment([Name] , [MRN] , [HUB ID] ,[Queue] ,[Last Event] ,[Last Event Date] ,[Last Fill]
				 , [Next Fill] ,[Need by Date] ,Category ,[Review Notes])
	SELECT [Name]
		 , MRN
		 , [HUB ID]
		 , [Queue]
		 , [Last Event]
		 , [Last Event Date]
		 , [Last Fill]
		 , [Next Fill]
		 , [Need by Date]
		 , Category
		 , [Review Notes]
	  FROM dbo.rpt_100_Dashboard_Review A
	  LEFT JOIN #302TestClaims B
	    ON A.MRN = B.note_patient_mrn
	 WHERE Category = 'Early Shipment'
	   AND CAST([Next Fill] AS DATE) != CAST(GETDATE() AS DATE)
	 ORDER BY MRN
END
       