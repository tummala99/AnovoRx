USE IncrelexDev
GO

IF (OBJECT_ID('dbo.usp_rpt_DB_Detail') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_DB_Detail
GO

CREATE PROCEDURE dbo.usp_rpt_DB_Detail
AS
/*
	Purpose: Consolidate and generate Patient Dispense Status Report data
	
	EXEC dbo.usp_rpt_DB_Detail

*/
BEGIN
	/*************[0039 Next Fill]*********/
	IF(OBJECT_ID('tempdb..#0039NextFill') IS NOT NULL)
		DROP TABLE #0039NextFill

	;WITH PendingOrders
	   AS
		(
		SELECT patient_mrn, order_status, order_rank, order_description, ordered_date_timestamp
			 , order_enterprise_list_code, order_enterprise_list_description
			 , order_discharge_date_timestamp, order_last_event, last_event_date
			 , order_fill_date_timestamp, order_next_fill_date_timestamp
		  FROM dbo.STG_Orders
		 WHERE (order_status='Pending')	--[0011 Pending Orders]		
		),
	ActiveOrders
	   AS
	   (
		SELECT AO.patient_mrn, Ao.[patient_mrn]-40119 AS [Patient ID], AO.order_status
			 , AO.order_rank, AO.order_description, AO.ordered_date_timestamp
			 , AO.order_enterprise_list_code, AO.order_enterprise_list_description
			 , AO.order_discharge_date_timestamp, AO.order_last_event, AO.last_event_date
			 , AO.order_fill_date_timestamp, AO.order_next_fill_date_timestamp
		  FROM dbo.STG_Orders AO 
		  LEFT JOIN PendingOrders PO	--[0011 Pending Orders] 
			ON AO.patient_mrn = PO.patient_mrn
		 WHERE (((AO.order_status)='Active') 
		   AND ((PO.patient_mrn) Is Null)) -- [0012 Active Orders]	   
	   )

		--SELECT * FROM PendingOrders
		--SELECT * FROM ActiveOrders -- 79
	
	SELECT DISTINCT AO.[Patient ID], AO.patient_mrn
		 , Max(AO.order_fill_date_timestamp) AS MaxOforder_fill_date_timestamp
		 , AO.order_next_fill_date_timestamp
	  INTO #0039NextFill
	  FROM ActiveOrders AO	--[0012 Active Orders]	 
	 GROUP BY AO.[Patient ID], AO.patient_mrn, AO.order_next_fill_date_timestamp
	HAVING (MAX(AO.order_fill_date_timestamp) Is Not NULL AND (Max(AO.order_fill_date_timestamp)>'1/1/2020'))
	
	/*************[0038 Exhaust Date]*********/
	IF(OBJECT_ID('tempdb..#0038ExhaustDate') IS NOT NULL)
		DROP TABLE #0038ExhaustDate

	;WITH LastDispense
	   AS
		(
		SELECT mrn, Max(dispense_date) AS MaxOfdispense_date
		  FROM dbo.STG_Dispense 
		 GROUP BY mrn -- [0007 Last Dispense] -- 96
		),
	DaySupply
	  AS
		(
		SELECT DISTINCT LD.[mrn]-40119 AS [Patient ID], LD.mrn, LD.MaxOfdispense_date
			 , Max(D.dispense_therapy_days) AS MaxOfdispense_therapy_days
		  FROM LastDispense LD 
		 INNER JOIN dbo.STG_Dispense D
		    ON LD.MaxOfdispense_date = D.dispense_date 
		   AND LD.mrn = D.mrn
		 GROUP BY LD.[mrn]-40119, LD.mrn, LD.MaxOfdispense_date -- [0037 Days Supply]
		)

	--SELECT * FROM DaySupply	
	SELECT [Patient ID]
		 , mrn, MaxOfdispense_date
		 , MaxOfdispense_therapy_days
		 --, [maxofdispense_date]+[maxofdispense_therapy_days]+1 AS [Exhaust Date]
		 , DATEADD(DAY,CAST([maxofdispense_therapy_days] AS INT) + 1, [maxofdispense_date]) AS [Exhaust Date]
	  INTO #0038ExhaustDate
	  FROM DaySupply

	/************[0040 Dispense Type]******************/
	IF(OBJECT_ID('tempdb..#0040DispenseType') IS NOT NULL)
		DROP TABLE #0040DispenseType
	SELECT DISTINCT D.mrn, [mrn]-40119 AS [Patient ID]
	     , D.dispense_date		 		 
		 , CASE WHEN [line9] Like '%Starter%' THEN 'Quick Start'
				WHEN [line9] Like '%Bridge%' THEN 'Bridge'
				WHEN [line9] Like '%Comp%' THEN 'PAP'
				ELSE 'Commercial'
		   END AS [Dispense Type]
	  INTO #0040DispenseType
	  FROM dbo.STG_Dispense D
	/**************[0041 First Dispense Type]*********************/
	IF(OBJECT_ID('tempdb..#0041FirstDispenseType') IS NOT NULL)
		DROP TABLE #0041FirstDispenseType
	;WITH FirstDispenseType
	   AS
		(
		SELECT mrn, [mrn]-40119 AS [Patient ID], Min(dispense_date) AS MinOfdispense_date
		  FROM dbo.STG_Dispense
		 GROUP BY mrn, [mrn]-40119 --[0022 First Dispense]
		)	

	SELECT FD.mrn, FD.[Patient ID], DT.dispense_date, DT.[Dispense Type]
	 INTO #0041FirstDispenseType
     FROM FirstDispenseType FD--[0022 First Dispense] 
	 LEFT JOIN #0040DispenseType DT 
	   ON (FD.MinOfdispense_date = DT.dispense_date) 
	  AND (FD.mrn = DT.mrn);

	/*************[Secondaries Active]***************/
	--;WITH SecondariesActive
	--   AS
	--	(
	--	SELECT mrn, [mrn]-40119 AS [Patient ID], secondary_payer_type, secondary_payer, secondary_insurance_status
	--	  FROM dbo.STG_Patients
	--	 WHERE (secondary_insurance_status<>'Inactive')		
	--	)
	/***********[64 Primary PA Appeal Status]*************/
	IF(OBJECT_ID('tempdb..#64PrimaryPAAppealStatus') IS NOT NULL)
		DROP TABLE #64PrimaryPAAppealStatus
	
	;WITH PrimaryPAApp
	   AS
		(
		SELECT note_patient_mrn, note_subject, note_entered_date, note_sys_id
		  FROM dbo.STG_PAAppealNotes
		 WHERE (note_subject Like '%Primary%') --146--[60 PrimaryPAApp]		
		)
	,MaxPrimaryPA
		AS
		(
		SELECT note_patient_mrn AS MRN, Max(note_entered_date) AS MaxOfnote_entered_date
			 , Max(note_sys_id) AS MaxOfnote_sys_id
		  FROM PrimaryPAApp
		 GROUP BY note_patient_mrn	--[62 Max Primary PA]
		)

	--SELECT * FROM MaxPrimaryPA -- 20
	SELECT [MRN]-40119 AS [Patient ID], PPA.note_sys_id, PPA.note_patient_mrn AS MRN
		 , IIf(PPA.[note_subject] Like ANM.[Note Subject],ANM.[Primary],'') AS [PA/Appeal Status]
		 , MPA.MaxOfnote_entered_date AS [PA/Appeal Status Date]
	  INTO #64PrimaryPAAppealStatus
	  FROM MaxPrimaryPA MPA 
	  LEFT JOIN PrimaryPAApp PPA
	    ON MPA.MaxOfnote_sys_id = PPA.note_sys_id 
	   AND MPA.MRN = PPA.note_patient_mrn 
	  LEFT JOIN dbo.STG_AuthNoteMapping ANM
	    ON PPA.note_subject = ANM.[Note Subject]
	 WHERE (((IIf(PPA.[note_subject] Like '%No Longer%',NULL,MPA.[MaxOfnote_entered_date])) Is Not Null))
	 ORDER BY PPA.note_sys_id DESC , MPA.MaxOfnote_entered_date DESC;

	/***********[65 Secondary PA Appeal Status]*******************/
	IF(OBJECT_ID('tempdb..#65SecondaryPAAppealStatus') IS NOT NULL)
		DROP TABLE #65SecondaryPAAppealStatus

	;WITH SecondaryPAApp
	   AS
		(
		SELECT note_patient_mrn, note_subject, note_entered_date, note_sys_id
		  FROM dbo.STG_PAAppealNotes
		 WHERE (note_subject Like '%Secondary%') --146--[61 SecondaryPAApp]		
		)
	,MaxSecondaryPA
		AS
		(
		SELECT note_patient_mrn AS MRN, Max(note_entered_date) AS MaxOfnote_entered_date
			 , Max(note_sys_id) AS MaxOfnote_sys_id
		  FROM SecondaryPAApp
		 GROUP BY note_patient_mrn	--[63 Max Secondary PA]
		)

	--SELECT * FROM MaxSecondaryPA -- 20	
	SELECT MSPA.MRN-40119 AS [Patient ID], SPA.note_sys_id, SPA.note_patient_mrn AS MRN
		 , IIf(SPA.[note_subject] Like ANM.[Note Subject],ANM.[Secondary],'') AS [Secondary PA/Appeal Status]
		 , MSPA.MaxOfnote_entered_date AS [Secondary PA/Appeal Status Date]
	  INTO #65SecondaryPAAppealStatus
	  FROM MaxSecondaryPA MSPA 
	  LEFT JOIN SecondaryPAApp SPA
	    ON MSPA.MaxOfnote_sys_id = SPA.note_sys_id 
	   AND MSPA.MRN = SPA.note_patient_mrn 
	  LEFT JOIN dbo.STG_AuthNoteMapping ANM
	    ON SPA.note_subject = ANM.[Note Subject]
	 WHERE (((IIf(SPA.[note_subject] Like '%No Longer%',NULL,MSPA.[MaxOfnote_entered_date])) Is Not Null))
	 ORDER BY SPA.note_sys_id DESC , MSPA.MaxOfnote_entered_date DESC;			
		
	/***********[0045 Referral Source]***************/
	IF(OBJECT_ID('tempdb..#0045ReferralSource') IS NOT NULL)
		DROP TABLE #0045ReferralSource
	SELECT mrn, [mrn]-40119 AS [Patient ID], referral_source, referral_organization
		 --, IIf([referral_organization] Like "Walgreens*","Walgreens Specialty",IIf([referral_organization] Like "Accredo*","Accredo",IIf([referral_organization] Like "*Optum*","Optum",IIf([referral_organization] Like "*CVS*","CVS",IIf(IsNull([referral_organization]),"","HCP"))))) AS [Referral Source]
		 , CASE WHEN [referral_organization] Like 'Walgreens%' THEN 'Walgreens Specialty'
				WHEN [referral_organization] Like 'Accredo%' THEN 'Accredo'
				WHEN [referral_organization] Like '%Optum%' THEN 'Optum'
				WHEN [referral_organization] Like '%CVS%' THEN 'CVS'
				ELSE 'HCP'
		   END AS [Referral Source]
	  INTO #0045ReferralSource
	  FROM dbo.STG_Patients;
	/**************************************Final Query****************************************************/
	IF(OBJECT_ID('dbo.STG_DB_Detail_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_DB_Detail_Output
	ELSE
	BEGIN
		CREATE TABLE dbo.STG_DB_Detail_Output (MRN INT,[Patient ID] INT,[Type] VARCHAR(255),[Referral Source Org] VARCHAR(255),[Creation Date] DATE,[Year of Birth] INT,
		[ICD-10] VARCHAR(255),[Status Type] VARCHAR(255),[Order Last Event Status] VARCHAR(255),[Status Date] DATE
		,[Patient Aging Days] INT,[Status Aging Days] INT,[Initial Dispense Date] DATE,[Initial Dispense Type] VARCHAR(255)
		,[Last Dispense Date] DATE,[Last Dispense Type] VARCHAR(255),[Therapy Days] INT,[Exhaust Date] DATE,[Next Fill Date] DATE
		,[HCP First] VARCHAR(255),[HCP Last] VARCHAR(255),[HCP NPI] VARCHAR(255),[HCP Address] VARCHAR(1000),[HCP City] VARCHAR(255)
		,[HCP State] VARCHAR(10),[HCP Zip] VARCHAR(20),[HCP Phone] VARCHAR(50),[Payer Type] VARCHAR(255),Payer VARCHAR(255)
		,[PA/Appeal Status] VARCHAR(255),[PA/Appeal Status Date] DATE
		,[Secondary Payer Type] VARCHAR(255),[Secondary Payer] VARCHAR(255),[Secondary PA/Appeal Status] VARCHAR(255),[Secondary PA/Appeal Status Date] DATE
		)
	END	

	INSERT INTO dbo.STG_DB_Detail_Output (MRN,[Patient ID],[Type],[Referral Source Org],[Creation Date],[Year of Birth],
		[ICD-10],[Status Type],[Order Last Event Status],[Status Date],[Patient Aging Days],[Status Aging Days],
		[Initial Dispense Date],[Initial Dispense Type],[Last Dispense Date],[Last Dispense Type],[Therapy Days],
		[Exhaust Date],[Next Fill Date],[HCP First],[HCP Last],[HCP NPI],[HCP Address],[HCP City],[HCP State],
		[HCP Zip],[HCP Phone],[Payer Type],Payer,[PA/Appeal Status],[PA/Appeal Status Date],
		[Secondary Payer Type],[Secondary Payer],[Secondary PA/Appeal Status],[Secondary PA/Appeal Status Date])
	
	SELECT S.[Patient ID]+40119 AS MRN, S.[Patient ID]
		 , IIF(S.[payer]='Alkindi Sprinkle PAP','PAP','Reimbursement') AS [Type]
		 , RS.[Referral Source] AS [Referral Source Org], S.[Creation Date]
		 , S.[Year of Birth], S.[ICD-10]
		 , IIF(S.[status type]='Pending',DBST.[dashboard status],S.[status type]) AS [Status Type]
		 , S.[Order Last Event Status], S.[Status Date]		 
		 , DATEDIFF(DAY,S.[Creation Date],GETDATE()) AS [Patient Aging Days]
		 , DATEDIFF(DAY,S.[status date],GETDATE()) AS [Status Aging Days]		 
		 , FD.MinOfdispense_date AS [Initial Dispense Date]
		 , FDT.[Dispense Type] AS [Initial Dispense Type], S.[Last Dispense Date]
		 , DT.[Dispense Type] AS [Last Dispense Type]
		 , ED.MaxOfdispense_therapy_days AS [Therapy Days]
		 , ED.[Exhaust Date]
		 , IIF(NF.[order_next_fill_date_timestamp] IS NOT NULL AND S.[status type]='Active',NF.[order_next_fill_date_timestamp],IIF(S.[status type]='Active',DATEADD(DAY,CAST(ED.[maxofdispense_therapy_days] AS INT),S.[last dispense date]),'')) AS [Next Fill Date]
		 , S.[HCP First], S.[HCP Last], S.[HCP NPI], S.[HCP Address]
		 , S.[HCP City], S.[HCP State], S.[HCP Zip], S.[HCP Phone]
		 , S.[Payer Type], S.Payer, PPAS.[PA/Appeal Status]
		 , PPAS.[PA/Appeal Status Date]
		 , IIF(SA.[secondary_payer_type] LIKE 'Compassionate','',IIF(SA.[secondary_payer_type] LIKE 'Foundation','',IIF(SA.[secondary_payer_type] LIKE 'Copay Card','',SA.[secondary_payer_type]))) AS [Secondary Payer Type]
		 , IIF(SA.[secondary_payer_type] LIKE 'Compassionate','',IIF(SA.[secondary_payer_type] LIKE 'Foundation','',IIF(SA.[secondary_payer_type] LIKE 'Copay Card','',SA.[secondary_payer]))) AS [Secondary Payer]
		 , SPAS.[Secondary PA/Appeal Status], SPAS.[Secondary PA/Appeal Status Date] 
	  FROM dbo.STG_100_Status_Output S
	  LEFT JOIN (
					SELECT mrn, [mrn]-40119 AS [Patient ID]
						 , Min(dispense_date) AS MinOfdispense_date
					  FROM dbo.STG_Dispense
					 GROUP BY mrn, [mrn]-40119
				) FD -- [0022 First Dispense]
	    ON S.[Patient ID] = FD.[Patient ID]
	  LEFT JOIN #0039NextFill NF
	    ON S.[Patient ID] = NF.[Patient ID]
	  LEFT JOIN #0038ExhaustDate ED
	    ON S.[Patient ID] = ED.[Patient ID]
	  LEFT JOIN dbo.STG_DBStatusType DBST
	    ON S.[Order Last Event Status] = DBST.[Order Last Event Status]
	  LEFT JOIN #0040DispenseType DT
	    ON S.[Patient ID] = DT.[Patient ID]
	   AND (S.[Last Dispense Date] = DT.dispense_date)
	  LEFT JOIN #0041FirstDispenseType FDT
	    ON S.[Patient ID] = FDT.[Patient ID]
	  LEFT JOIN (
				SELECT mrn, [mrn]-40119 AS [Patient ID], secondary_payer_type, secondary_payer, secondary_insurance_status
				  FROM dbo.STG_Patients
				 WHERE (secondary_insurance_status<>'Inactive')
				) SA
	    ON S.[Patient ID] = SA.[Patient ID]
	  LEFT JOIN #64PrimaryPAAppealStatus PPAS
	    ON S.[Patient ID] = PPAS.[Patient ID]
	  LEFT JOIN #65SecondaryPAAppealStatus SPAS
	    ON S.[Patient ID] = SPAS.[Patient ID]
	  LEFT JOIN #0045ReferralSource RS
	    ON S.[Patient ID] = RS.[Patient ID]

	--SELECT * FROM dbo.STG_DB_Detail_Output

END    