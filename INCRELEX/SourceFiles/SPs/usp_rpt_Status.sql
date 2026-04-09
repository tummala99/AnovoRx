IF (OBJECT_ID('dbo.usp_rpt_Status') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Status
GO

CREATE PROCEDURE dbo.usp_rpt_Status
AS
/*
	Purpose: Consolidate and generate Patient Dispense Status Report data
	
	EXEC dbo.usp_rpt_Status

*/
BEGIN

	/*****************************************/
	--[0011 Pending Orders] 
	IF(OBJECT_ID('tempdb..#0011PendingOrders') IS NOT NULL)
		DROP TABLE #0011PendingOrders

	SELECT O.patient_mrn, O.order_status, CAST(O.order_rank AS DECIMAL(4,1)) AS order_rank
		 , O.order_description
		 , CAST(NULLIF(O.ordered_date_timestamp,'') AS DATE) AS ordered_date_timestamp
		 , O.order_enterprise_list_code, O.order_enterprise_list_description
		 , O.order_discharge_date_timestamp, O.order_last_event, CAST(NULLIF(O.last_event_date,'') AS DATE) AS last_event_date 
		 , CAST(NULLIF(O.order_fill_date_timestamp,'') AS DATE) AS order_fill_date_timestamp 
		 , CAST(NULLIF(O.order_next_fill_date_timestamp,'') AS DATE) AS order_next_fill_date_timestamp
	  INTO #0011PendingOrders
	  FROM dbo.[STG_Orders] O
	 WHERE (((TRIM(O.order_status))='Pending'));

	IF(OBJECT_ID('tempdb..#0013OrdersList') IS NOT NULL)
		DROP TABLE #0013OrdersList

	SELECT O.patient_mrn, O.order_status, CAST(O.order_rank AS DECIMAL(4,1)) AS order_rank
		 , O.order_description
		 , CAST(NULLIF(O.ordered_date_timestamp,'') AS DATE) AS ordered_date_timestamp
		 , O.order_enterprise_list_code, O.order_enterprise_list_description
		 , O.order_discharge_date_timestamp, O.order_last_event
		 , CAST(NULLIF(O.last_event_date,'') AS DATE) AS last_event_date 
		 , CAST(NULLIF(O.order_fill_date_timestamp,'') AS DATE) AS order_fill_date_timestamp
		 , CAST(NULLIF(O.order_next_fill_date_timestamp,'') AS DATE) AS order_next_fill_date_timestamp
	  INTO #0013OrdersList
	  FROM dbo.[STG_Orders] O
	  LEFT JOIN #0011PendingOrders PO 
	    ON O.patient_mrn = PO.patient_mrn
	 WHERE ((TRIM(O.order_status)='Active') 
	   AND ((PO.patient_mrn) IS NULL))
	 UNION 	
	SELECT O.patient_mrn, O.order_status, CAST(O.order_rank AS DECIMAL(4,1)) AS order_rank
		 , O.order_description
		 , CAST(NULLIF(O.ordered_date_timestamp,'') AS DATE) AS ordered_date_timestamp
		 , O.order_enterprise_list_code, O.order_enterprise_list_description
		 , O.order_discharge_date_timestamp, O.order_last_event
		 , CAST(NULLIF(O.last_event_date,'') AS DATE) AS last_event_date 
		 , CAST(NULLIF(O.order_fill_date_timestamp,'') AS DATE) AS order_fill_date_timestamp
		 , CAST(NULLIF(O.order_next_fill_date_timestamp,'') AS DATE) AS order_next_fill_date_timestamp
	  FROM #0011PendingOrders O

	IF(OBJECT_ID('tempdb..#0014UniqueOrders') IS NOT NULL)
		DROP TABLE #0014UniqueOrders
	
	SELECT OL.patient_mrn
		 , MIN(OL.order_rank) AS MinOforder_rank
	  INTO #0014UniqueOrders	
	  FROM #0013OrdersList OL
	 GROUP BY OL.patient_mrn;

	IF(OBJECT_ID('tempdb..#0010StatusDate') IS NOT NULL)
		DROP TABLE #0010StatusDate

	SELECT T.patient_mrn AS MRN, MAX(MaxOfordered_date_timestamp) AS StatusDate
	  INTO #0010StatusDate
	  FROM 
		 (	--[0009 Combined Dates]
			SELECT O.patient_mrn, MAX(CAST(NULLIF(O.ordered_date_timestamp,'') AS DATE)) AS MaxOfordered_date_timestamp
			  FROM dbo.[STG_Orders] O
			 GROUP BY O.patient_mrn
			 UNION
			SELECT Q.mrn, MAX(CAST(NULLIF(Q.move_date,'') AS DATE)) AS MaxOfmove_date
			  FROM dbo.[STG_Queue] Q
			 GROUP BY Q.mrn
			 UNION
			SELECT O.patient_mrn, MAX(CAST(NULLIF(O.last_event_date,'') AS DATE)) AS MaxOflast_event_date
			  FROM dbo.[STG_Orders] O
			 GROUP BY O.patient_mrn
			HAVING (((MAX(NULLIF(O.last_event_date,''))) IS NOT NULL))
			 UNION 
			SELECT D.mrn, MAX(CAST(NULLIF(D.dispense_date,'') AS DATE)) AS MaxOfdispense_date
			  FROM dbo.[STG_Dispense] D
			 GROUP BY D.mrn
		) AS T
	  GROUP BY T.patient_mrn		
	  	

	--------------2 nd UNION------------------
	--SELECT * FROM dbo.[STG_Notes]
	--0016 Closed Notes
	IF(OBJECT_ID('tempdb..#0016ClosedNotes') IS NOT NULL)
		DROP TABLE #0016ClosedNotes

	SELECT note_patient_mrn, CAST(NULLIF(note_entered_date,'') AS DATE) AS note_entered_date, note_subject, note_body
	  INTO #0016ClosedNotes
	  FROM dbo.[STG_Notes] 
	 WHERE (TRIM(note_subject) LIKE 'Patient Discharged%' OR TRIM(note_subject) LIKE 'No Start%') 
	   AND note_sys_id<>646111;

	--[0017 Last Closed Note]
	IF(OBJECT_ID('tempdb..#0017LastClosedNote') IS NOT NULL)
		DROP TABLE #0017LastClosedNote

	SELECT note_patient_mrn, Max(CAST(NULLIF(note_entered_date,'') AS DATE)) AS MaxOfnote_entered_date
	  INTO #0017LastClosedNote
	  FROM #0016ClosedNotes
	GROUP BY note_patient_mrn;

			   	
	-----------------------0020 Status Detail-------------------------------
	IF(OBJECT_ID('tempdb..#0020StatusDetail') IS NOT NULL)
		DROP TABLE #0020StatusDetail

	SELECT * 
	  INTO #0020StatusDetail
	  FROM
		 (
			SELECT DISTINCT A.patient_mrn
				 , SD.StatusDate
				 , OLEM.[Order Last Event Status]
				 , IIF(D.[mrn] IS NULL,'Pending','Active') AS [Status Type]				 
			  FROM #0013OrdersList A
			 INNER JOIN #0014UniqueOrders B
				ON A.order_rank = B.MinOforder_rank
			   AND A.patient_mrn = B.patient_mrn
			  LEFT JOIN dbo.STG_OrderLastEventMapping OLEM
				ON TRIM(A.order_enterprise_list_description) = TRIM(OLEM.[Queue]) 
			   AND A.order_last_event = OLEM.[Order Last Event]
			  LEFT JOIN dbo.[STG_Dispense] D
				ON A.patient_mrn = D.mrn
			  LEFT JOIN #0010StatusDate SD
				ON A.patient_mrn = SD.MRN -- 94

			 UNION

			SELECT CN.note_patient_mrn, CN.note_entered_date
				 , CN.note_subject, 'Closed' AS [Status Type]
			  FROM dbo.[STG_Patients] P
			 INNER JOIN #0016ClosedNotes CN
				ON P.mrn = CN.note_patient_mrn
			 INNER JOIN #0017LastClosedNote LCN
				ON CN.note_patient_mrn = LCN.note_patient_mrn
			   AND CN.note_entered_date = LCN.MaxOfnote_entered_date
			 WHERE CN.note_patient_mrn NOT IN (229879,229745)
			   AND (TRIM(CN.note_subject) Like 'Patient Discharged%') 
			   AND (TRIM(P.patient_status) In ('Cancelled','Inactive'))

		     UNION
			SELECT CN.note_patient_mrn, CN.note_entered_date
				 --, IIF([note_body] LIKE 'Patient unreachable%','No Start: Patient Unreachable'
					--				, IIF([note_body] LIKE 'Patient decision%','No Start: Patient Decision',IIF([note_body] LIKE 'copay%','No Start: Copay too High','No Start: MD Decision'))) AS Reason
				 , CASE WHEN TRIM([note_body]) LIKE 'Patient unreachable%' THEN 'No Start: Patient Unreachable'
					    WHEN TRIM([note_body]) LIKE 'Patient decision%' THEN 'No Start: Patient Decision'
						WHEN TRIM([note_body]) LIKE 'copay%' THEN 'No Start: Copay too High'
						ELSE 'No Start: MD Decision'
				   END AS Reason
				 , 'Closed' AS [Status Type] 
			  FROM dbo.[STG_Patients] P
			 INNER JOIN #0016ClosedNotes CN
				ON P.mrn = CN.note_patient_mrn
			 INNER JOIN #0017LastClosedNote LCN
				ON CN.note_patient_mrn = LCN.note_patient_mrn
			   AND CN.note_entered_date = LCN.MaxOfnote_entered_date
			 WHERE ((CN.note_patient_mrn<>231348) 
			   AND (TRIM(CN.note_subject)='No Start')
			   AND (TRIM(P.patient_status) IN ('Cancelled','Inactive','on hold')))
		) AS T

		--SELECT * FROM #0020StatusDetail

		/*****************0024 Patient Data******************/

		IF(OBJECT_ID('tempdb..#0024PatientData') IS NOT NULL)
			DROP TABLE #0024PatientData

		SELECT IIf(P.[mrn]=232086,'3/15/2022',P.[patient_referral_date]) AS [Creation Date]
			 , P.mrn
			 , Left(P.[first_name],1) + Left(P.[last_name],1) AS [Patient Initials]
			 , DATEPART(YEAR,CAST(NULLIF(P.[patient_date_of_birth],'') AS DATE)) AS [Year of Birth]
			 , P.patient_primary_icd10 AS [ICD-10]
			 , LD.MaxOfdispense_date AS [Last Dispensed Date]
			 , P.physician_first AS [HCP First]
			 , P.physician_last AS [HCP Last]
			 , P.physician_npi AS [HCP NPI]
			 , P.physician_address AS [HCP Address]
			 , P.physician_city AS [HCP City]
			 , P.physician_state AS [HCP State]
			 , P.physician_zip AS [HCP Zip]
			 , P.physician_phone AS [HCP Phone]
			 , P.physician_email AS [HCP Email]
		  INTO #0024PatientData
		  FROM dbo.STG_Patients P
		  LEFT JOIN (SELECT mrn, Max(CAST(NULLIF(dispense_date,'') AS DATE)) AS MaxOfdispense_date
					   FROM dbo.STG_Dispense
					  GROUP BY mrn
					) LD 
		    ON P.mrn = LD.mrn;

		--SELECT * FROM #0024PatientData
		/****************[0026 Report Payer]**********************/
		IF(OBJECT_ID('tempdb..#0026ReportPayer') IS NOT NULL)
			DROP TABLE #0026ReportPayer

		SELECT P.mrn, P.primary_payer_type AS [Payer Type], P.primary_payer AS Payer
			 --, IIf(SAP.[secondary_payer_type] Like 'Compassionate','',IIf(SAP.[secondary_payer_type] Like 'Foundation','',IIf(SAP.[secondary_payer_type] Like 'Copay Card','',P.[secondary_payer_type]))) AS [Secondary Payer Type]
			 --, IIf(SAP.[secondary_payer_type] Like 'Compassionate','',IIf(SAP.[secondary_payer_type] Like 'Foundation','',IIf(SAP.[secondary_payer_type] Like 'Copay Card','',P.[secondary_payer]))) AS [Secondary Payer]
			 , IIf(TRIM(SAP.[secondary_payer_type]) IN ('Compassionate','Foundation','Copay Card'),'',SAP.[secondary_payer_type]) AS [Secondary Payer Type]
			 , IIf(TRIM(SAP.[secondary_payer_type]) IN ('Compassionate','Foundation','Copay Card'),'',SAP.[secondary_payer]) AS [Secondary Payer]
		  INTO #0026ReportPayer
		  FROM dbo.STG_Patients P 
		  LEFT JOIN (
					SELECT P.mrn, [mrn]-40119 AS ID, P.secondary_payer_type
						 , P.secondary_payer
						 , P.secondary_insurance_status
					  FROM dbo.STG_Patients P
					 WHERE (ISNULL(TRIM(P.secondary_insurance_status),'Active')<>'Inactive')	
			 ) SAP
		    ON P.mrn = SAP.mrn;

		--SELECT * FROM #0026ReportPayer
		--SELECT * FROM dbo.STG_Patients WHERE [secondary_payer_type] LIKE 'Compassionate%'
		
		/****************0028 QS Offer******************************/
		IF(OBJECT_ID('tempdb..#0028QSOffer') IS NOT NULL)
			DROP TABLE #0028QSOffer

		SELECT N.note_patient_mrn AS mrn, N.note_subject
			 , IIf([note_Subject] Like 'Quick Start Declined%' And [note_patient_mrn] Not In (235083),SUBSTRING([note_subject],23,LEN([note_subject])),'') AS [QS Declined]
			 , IIf([note_subject]='Quick Start Accepted','Y','') AS [QS Accepted]
		  INTO #0028QSOffer
		  FROM dbo.STG_Notes N
		 WHERE ((TRIM(N.note_subject) Like 'Quick Start%') AND ((IIf(TRIM([note_Subject]) Like 'Quick Start Declined%' And [note_patient_mrn] Not In (235083),SUBSTRING(TRIM([note_subject]),23,LEN(TRIM([note_subject]))),null)) Is Not Null)) 
				OR (((TRIM(N.note_subject)) Like 'Quick Start%') AND ((IIf(TRIM([note_subject]) ='Quick Start Accepted','Y',null)) Is Not Null));
		/****************0030 Optin**************************/
		IF(OBJECT_ID('tempdb..#0030Optin') IS NOT NULL)
			DROP TABLE #0030Optin

		SELECT O.Mrn, O.[_2_did_anovo_receive_a_completed_copy_of_the_opt_in_letter_] AS OptIn
		  INTO #0030Optin
		  FROM dbo.STG_Optin O
		  LEFT JOIN dbo.STG_Notes N 
			ON O.Mrn = N.note_patient_mrn
		   AND (TRIM(N.note_subject) Like 'Pt Opt-Out%')
		 WHERE (((O.[_2_did_anovo_receive_a_completed_copy_of_the_opt_in_letter_])='Yes') 
				AND ((N.note_patient_mrn) Is Null))
		/****************0033 PA TAT************************/
		IF(OBJECT_ID('tempdb..#0033PATAT') IS NOT NULL)
			DROP TABLE #0033PATAT

		;WITH PAApproved
		AS
			(
			SELECT DISTINCT N.note_patient_mrn AS mrn, MIN(CAST(N.note_entered_date AS DATE))  AS [PA Approved]
			FROM dbo.STG_Notes N
			WHERE N.note_subject = 'prior auth approved' --'Prior Auth Primary Approved'--
			GROUP BY N.note_patient_mrn, N.note_subject	
			),
		MinOfdispense
		AS
			(
			SELECT DISTINCT D.mrn, MIN(CAST(D.dispense_date AS DATE))  AS MinOfdispense_date
			  FROM dbo.STG_Dispense D
			 GROUP BY D.mrn, D.line9
			HAVING (((D.line9) Like '%Starter'))
			)
	
		SELECT A.mrn, DATEDIFF(DAY,A.[PA Approved],B.MinOfdispense_date) AS [TAT QS to PA]
		  INTO #0033PATAT
		  FROM PAApproved A
		 INNER JOIN MinOfdispense B
		    ON A.mrn = B.mrn
		 WHERE DATEDIFF(DAY,A.[PA Approved],B.MinOfdispense_date) >= 0
		   AND DATEDIFF(DAY,A.[PA Approved],B.MinOfdispense_date) <= 45
	
		--SELECT * FROM #0033PATAT

		/*****************[Scheduled Ship Date]********************/
		IF(OBJECT_ID('tempdb..#ScheduledShipDate') IS NOT NULL)
			DROP TABLE #ScheduledShipDate

		SELECT O.patient_mrn, O.order_enterprise_list_description
			 , CAST(NULLIF(O.order_fill_date_timestamp,'') AS DATE) AS order_fill_date_timestamp
			 , O.order_description
		  INTO #ScheduledShipDate
		  FROM dbo.STG_Orders O
		 WHERE ((TRIM(O.order_enterprise_list_description) Like 'C%') 
			OR (TRIM(O.order_enterprise_list_description) Like 'E%') 
			OR (TRIM(O.order_enterprise_list_description) Like 'D%'));

		--SELECT * FROM #ScheduledShipDate

		/****************[0053 New vs Transfer]**************/
		IF(OBJECT_ID('tempdb..#0053NewvsTransfer') IS NOT NULL)
			DROP TABLE #0053NewvsTransfer

		;WITH WecomeCallNotesAll --0050 Wecome Call Notes All
		  AS
		  (
			SELECT N.note_patient_mrn, CAST(N.note_sys_id AS BIGINT) AS note_sys_id
				 , CAST(NULLIF(N.note_entered_date,'') AS DATE) AS note_entered_date
				 , N.note_subject
			  FROM dbo.STG_Notes N
			 WHERE (N.note_subject LIKE '%Welcome Call')
		  ),
		  MaxOfWelcomeCall -- [0051 Max of Welcome Call]
		  AS
		  (
			SELECT note_patient_mrn, MAX(note_sys_id) AS MaxOfnote_sys_id
			  FROM WecomeCallNotesAll
			 GROUP BY note_patient_mrn
		  ),
		  WelcomeNotesbyPatient--[0052 Welcome Notes by Patient]
		  AS
		  (
						  
			SELECT A.note_patient_mrn, A.note_sys_id, A.note_entered_date, A.note_subject
			FROM WecomeCallNotesAll A
			INNER JOIN MaxOfWelcomeCall B
				ON A.note_sys_id = MaxOfnote_sys_id
		  ) 	

		SELECT note_patient_mrn, note_subject, note_entered_date
		     , IIF([note_subject] LIKE '%New%','Y',IIF([note_subject] LIKE '%Transfer%','N','')) AS [New to Treatment?]
		  INTO #0053NewvsTransfer
		  FROM WelcomeNotesbyPatient;
		
		--SELECT * FROM #0053NewvsTransfer
		/**************[64 Primary PA Appeal Status]***************************/
		IF(OBJECT_ID('tempdb..#64PrimaryPAAppealStatus') IS NOT NULL)
			DROP TABLE #64PrimaryPAAppealStatus

		;WITH PrimaryPAApp -- [60 PrimaryPAApp]
		AS
		(	
			SELECT note_patient_mrn, note_subject, CAST(NULLIF(note_entered_date,'') AS DATE) AS note_entered_date
				 , CAST(note_sys_id AS BIGINT) AS note_sys_id
			  FROM dbo.STG_PAAppealNotes
			 WHERE (note_subject LIKE '%Primary%')
		),
		MaxPrimaryPA -- [62 Max Primary PA] 
		AS
		(
			SELECT note_patient_mrn AS MRN, MAX(note_entered_date) AS MaxOfnote_entered_date
				 , MAX(note_sys_id) AS MaxOfnote_sys_id
			  FROM PrimaryPAApp
			 GROUP BY note_patient_mrn
		)
		--SELECT * FROM MaxPrimaryPA
		
		SELECT [MRN]-40119 AS ID, A.note_sys_id, A.note_patient_mrn AS MRN
			 , IIF(A.[note_subject] LIKE C.[Note Subject],C.[Primary],'') AS [PA/Appeal Status]
			 , B.MaxOfnote_entered_date AS [PA/Appeal Status Date]
		  INTO #64PrimaryPAAppealStatus
		  FROM PrimaryPAApp A
		 INNER JOIN MaxPrimaryPA B 
		    ON (B.MaxOfnote_sys_id = A.note_sys_id) 
		   AND (B.MRN = A.note_patient_mrn) 
		  LEFT JOIN dbo.STG_AuthNoteMapping C
		    ON TRIM(A.note_subject) = TRIM(C.[Note Subject])
		 WHERE (((IIf(A.[note_subject] Like '%No Longer%','',[MaxOfnote_entered_date])) Is Not Null))
		 ORDER BY A.note_sys_id DESC , B.MaxOfnote_entered_date DESC;

		 --SELECT * FROM #64PrimaryPAAppealStatus
		 
		 /***************[65 Secondary PA Appeal Status] ****************/
		 IF(OBJECT_ID('tempdb..#65SecondaryPAAppealStatus') IS NOT NULL)
			DROP TABLE #65SecondaryPAAppealStatus

		 ;WITH SecondaryPAApp -- [61 SecondaryPAApp]
		 AS
		 (
			SELECT note_patient_mrn, note_subject, CAST(NULLIF(note_entered_date,'') AS DATE) AS note_entered_date
				 , CAST(note_sys_id AS BIGINT) AS note_sys_id
			  FROM dbo.STG_PAAppealNotes
			 WHERE (((note_subject) Like '%Secondary%'))
		 ),
		 MaxSecondaryPA --[63 Max Secondary PA]
		 AS
		 (
			SELECT note_patient_mrn AS MRN
				 , Max(note_sys_id) AS MaxOfnote_sys_id
				 , Max(note_entered_date) AS MaxOfnote_entered_date
			  FROM SecondaryPAApp
			 GROUP BY note_patient_mrn
		 )

		--SELECT * FROM MaxSecondaryPA
		SELECT [note_patient_mrn]-40119 AS ID
			 , A.note_sys_id
			 , A.note_patient_mrn AS MRN
			 , IIf(A.[note_subject] Like C.[Note Subject],C.[Secondary],'') AS [Secondary PA/Appeal Status]
			 , B.[MaxOfnote_entered_date] AS [Secondary PA/Appeal Status Date]
		  INTO #65SecondaryPAAppealStatus	
		  FROM SecondaryPAApp A
		 INNER JOIN MaxSecondaryPA B
		    ON B.MaxOfnote_sys_id = A.note_sys_id 
		   AND B.MRN = A.note_patient_mrn
		  LEFT JOIN dbo.STG_AuthNoteMapping C
		    ON TRIM(A.note_subject) = TRIM(C.[Note Subject])
		 WHERE (((IIf(A.[note_subject] Like '%No Longer%','',B.[MaxOfnote_entered_date])) Is Not Null))
		 ORDER BY B.[MaxOfnote_entered_date] DESC

		 --SELECT * FROM #65SecondaryPAAppealStatus
			
		/****************100_Status *************************/

		IF(OBJECT_ID('dbo.STG_100_Status_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_100_Status_Output
		ELSE
		BEGIN
			CREATE TABLE dbo.STG_100_Status_Output(ID INT IDENTITY(1,1)
				,[Creation Date] DATE, [Patient ID] INT, [Patient Initials] VARCHAR(2),[Year of Birth] INT  
				,[ICD-10] VARCHAR(255),[Status Type] VARCHAR(50), [Order Last Event Status] VARCHAR(255),[Status Date] DATE
				,[Scheduled Ship Date] DATE,[Last Dispense Date] DATE,[New to Treatment?] VARCHAR(5),[HCP First] VARCHAR(255)
				,[HCP Last] VARCHAR(255),[HCP NPI] VARCHAR(255),[HCP Address] VARCHAR(1000),[HCP City] VARCHAR(255)
				,[HCP State] VARCHAR(10),[HCP Zip] VARCHAR(20),[HCP Phone] VARCHAR(50),[HCP Email] VARCHAR(50)
				,[Payer Type] VARCHAR(255),Payer VARCHAR(255),[Primary PA/Appeal Status] VARCHAR(255)
				,[Primary PA/Appeal Status Date] DATE,[Secondary Payer Type] VARCHAR(255),[Secondary Payer] VARCHAR(255)
				,[Secondary PA/Appeal Status] VARCHAR(255),[Secondary PA/Appeal Status Date] DATE
				,[Quick Start Shipment] VARCHAR(10),[TAT QS to PA] VARCHAR(50),[QS Declined] VARCHAR(255)
				,[QS Accepted] VARCHAR(255),OptIn VARCHAR(255)
				)
		END

		INSERT INTO dbo.STG_100_Status_Output ([Creation Date], [Patient ID], [Patient Initials] ,[Year of Birth]   
				,[ICD-10] ,[Status Type] , [Order Last Event Status] ,[Status Date],[Scheduled Ship Date] ,[Last Dispense Date] 
				,[New to Treatment?] ,[HCP First] ,[HCP Last] ,[HCP NPI],[HCP Address] ,[HCP City],[HCP State] ,[HCP Zip] ,[HCP Phone] 
				,[HCP Email],[Payer Type] ,Payer ,[Primary PA/Appeal Status] ,[Primary PA/Appeal Status Date] ,[Secondary Payer Type] 
				,[Secondary Payer] ,[Secondary PA/Appeal Status] ,[Secondary PA/Appeal Status Date] ,[Quick Start Shipment] 
				,[TAT QS to PA] ,[QS Declined],[QS Accepted] ,OptIn)
		SELECT DISTINCT NULLIF(PD.[Creation Date],''), PD.[mrn]-40119 AS [Patient ID], PD.[Patient Initials], PD.[Year of Birth]
			 , PD.[ICD-10] AS [ICD-10], SD.[Status Type], SD.[Order Last Event Status], NULLIF(SD.StatusDate,'') AS [Status Date]
			 , NULLIF(SSD.order_fill_date_timestamp,'') AS [Scheduled Ship Date], NULLIF(LD.MaxOfdispense_date,'') AS [Last Dispense Date]
			 , NT.[New to Treatment?], PD.[HCP First], PD.[HCP Last], PD.[HCP NPI], PD.[HCP Address]
			 , PD.[HCP City], PD.[HCP State], PD.[HCP Zip], PD.[HCP Phone], PD.[HCP Email], RP.[Payer Type], RP.Payer
			 , PPA.[PA/Appeal Status] AS [Primary PA/Appeal Status], NULLIF(PPA.[PA/Appeal Status Date],'') AS [Primary PA/Appeal Status Date]
			 , RP.[Secondary Payer Type], RP.[Secondary Payer], SPA.[Secondary PA/Appeal Status]
			 , NULLIF(SPA.[Secondary PA/Appeal Status Date],''), QSS.[Quick Start Shipment]
			 , TAT.[TAT QS to PA], QSO.[QS Declined], QSO.[QS Accepted], Opt.OptIn
		  FROM #0024PatientData PD
		  LEFT JOIN #0020StatusDetail SD
		    ON PD.mrn = SD.patient_mrn
		  LEFT JOIN 
			 (
				SELECT mrn, Max(dispense_date) AS MaxOfdispense_date
				  FROM dbo.STG_Dispense
				 GROUP BY mrn
			 ) AS LD
		    ON PD.mrn = LD.mrn
		  LEFT JOIN #0026ReportPayer RP
		    ON PD.mrn = RP.mrn
		  LEFT JOIN
			 (
			  SELECT DISTINCT mrn, IIf([line9] Like '%Starter%','Y','') AS [Quick Start Shipment]
				FROM dbo.STG_Dispense
				--WHERE [line9] LIKE '%Starter%'
			   WHERE (((IIf([line9] Like '%Starter%','Y',NULL)) Is Not Null))
			 ) AS QSS
		    ON PD.mrn = QSS.mrn		
		  LEFT JOIN #0028QSOffer QSO
		    ON PD.mrn = QSO.mrn
		  LEFT JOIN #0030Optin Opt
		    ON PD.mrn = Opt.mrn
		  LEFT JOIN #0033PATAT TAT
		    ON TAT.mrn = PD.mrn
		  LEFT JOIN #ScheduledShipDate SSD
		    ON PD.mrn = SSD.patient_mrn
		  LEFT JOIN #0053NewvsTransfer NT
		    ON PD.mrn = NT.note_patient_mrn
		  LEFT JOIN #64PrimaryPAAppealStatus PPA
		    ON PD.mrn = PPA.MRN
		  LEFT JOIN #65SecondaryPAAppealStatus SPA
		    ON PD.mrn = SPA.MRN
		
	--SELECT * FROM dbo.STG_100_Status_Output	

END