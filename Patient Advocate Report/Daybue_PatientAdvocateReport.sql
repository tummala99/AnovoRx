USE TherapyAdvocateDaybueDev
SELECT * FROM dbo.[STG_DaybueAttempttoContact]
SELECT * FROM dbo.[STG_DaybueCommunicationNotes]
SELECT * FROM dbo.[STG_DaybueDC]
SELECT * FROM dbo.STG_DaybueDoseChange
SELECT * FROM dbo.[STG_DaybueNewOrders]
SELECT * FROM dbo.[STG_DaybueNoGo]
SELECT * FROM dbo.[STG_DaybuePayable]
SELECT * FROM dbo.[STG_DaybuePrecallDOH]
SELECT * FROM dbo.[STG_DaybueScheduled]
SELECT * FROM dbo.[STG_DaybueTestClaims]
SELECT * FROM dbo.[STG_DaybueDispense]
SELECT * FROM dbo.[STG_DaybueOrders]
SELECT * FROM dbo.[STG_DaybuePatients]
SELECT * FROM [dbo].[STG_HUBCaseStatusReport]

CREATE  OR REPLACE  DATABASE ROLE IF NOT EXISTS  <NAME>
/*****************Final Report Tables************************/
SELECT * FROM dbo.rpt_100_Dashboard_Review ORDER BY MRN
SELECT * FROM dbo.rpt_200_Late_Shipment ORDER BY MRN
SELECT * FROM dbo.rpt_300_Early_Shipment ORDER BY MRN
SELECT * FROM dbo.rpt_400_Days_to_Exhaust ORDER BY MRN
SELECT * FROM dbo.rpt_500_No_Go ORDER BY MRN
SELECT * FROM dbo.rpt_600_Scheduled ORDER BY MRN
SELECT * FROM dbo.rpt_700_Dose_Change

SELECT * FROM dbo.rpt_100_Dashboard_Review WHERE MRN = 240927
SELECT MRN,COUNT(1) FROM dbo.rpt_600_Scheduled
 GROUP BY MRN
 HAVING COUNT(1) > 1

 SELECT MRN,COUNT(1) FROM dbo.rpt_700_Dose_Change
 GROUP BY MRN
 HAVING COUNT(1) > 1

--DROP TABLE dbo.rpt_100_Dashboard_Review
--DROP TABLE dbo.rpt_200_Late_Shipment
--DROP TABLE dbo.rpt_300_Early_Shipment 
--DROP TABLE dbo.rpt_400_Days_to_Exhaust 
--DROP TABLE dbo.rpt_500_No_Go

/*
	TRUNCATE TABLE dbo.[STG_DaybueAttempttoContact];
	TRUNCATE TABLE dbo.[STG_DaybueCommunicationNotes];
	TRUNCATE TABLE dbo.[STG_DaybueDC];
	TRUNCATE TABLE [dbo].[STG_DaybueDoseChange];
	TRUNCATE TABLE dbo.[STG_DaybueNewOrders];
	TRUNCATE TABLE dbo.[STG_DaybueNoGo];
	TRUNCATE TABLE dbo.[STG_DaybuePayable];
	TRUNCATE TABLE dbo.[STG_DaybuePrecallDOH];
	TRUNCATE TABLE dbo.[STG_DaybueScheduled];
	TRUNCATE TABLE dbo.[STG_DaybueTestClaims];
	TRUNCATE TABLE dbo.[STG_DaybueDispense];
	TRUNCATE TABLE dbo.[STG_DaybueOrders];
	TRUNCATE TABLE dbo.[STG_DaybuePatients];
	TRUNCATE TABLE [dbo].[STG_HUBCaseStatusReport];
		
*/

CREATE TABLE dbo.[STG_DaybueAttempttoContact] (
    [MRN] VARCHAR(50),
    [Date] VARCHAR(50),
    [Subject] VARCHAR(50),
    [Note] VARCHAR(500),
    [note_sys_id] VARCHAR(50),
	Import_Date DATETIME DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueCommunicationNotes] (
    [MRN] VARCHAR(50),
    [Date] VARCHAR(50),
    [Subject] VARCHAR(100),
    [Note] VARCHAR(4000),
    [note_sys_id] VARCHAR(50),
	Import_Date DATETIME DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueDC] (
    [Name] VARCHAR(50),
    [MRN] VARCHAR(50),
    [HUB ID] VARCHAR(50),
    [Discharge Date] VARCHAR(50),
    [Discharge] VARCHAR(50),
    [Discharge Note] VARCHAR(4000),
	Import_Date DATETIME DEFAULT GETDATE()
)

CREATE TABLE [dbo].[STG_DaybueDoseChange](
	[mrn] [VARCHAR](50) NULL,
	[dispense_date] [VARCHAR](50) NULL,
	[order_description] [VARCHAR](500) NULL,
	[order_original_rx_date] [VARCHAR](50) NULL,
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
) 

CREATE TABLE dbo.[STG_DaybueNewOrders] (
    [order_site_number] VARCHAR(50),
    [MRN] VARCHAR(50),
    [Patient Name] VARCHAR(100),
    [Order Description] VARCHAR(500),
    [Order Date] VARCHAR(50),
    [HCP NPI] VARCHAR(50),
    [Order HCP] VARCHAR(100),
    [order_status] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueNoGo] (
    [note_sys_id] VARCHAR(50),
    [note_patient_mrn] VARCHAR(50),
    [note_patient_sys_id] VARCHAR(50),
    [note_invoice_number] VARCHAR(50),
    [note_claim_number] VARCHAR(50),
    [note_user_sys_id] VARCHAR(50),
    [note_entered_date] VARCHAR(50),
    [note_follow_up_date] VARCHAR(50),
    [note_subject] VARCHAR(50),
    [note_body] VARCHAR(4000),
    [note_bill_note_yn] VARCHAR(50),
    [note_auto_yn] VARCHAR(50),
    [note_void_yn] VARCHAR(50),
    [note_follow_up_user_sys_id] VARCHAR(50),
    [note_follow_up_done_yn] VARCHAR(50),
    [note_type] VARCHAR(50),
    [company_sys_id] VARCHAR(50),
    [company_name] VARCHAR(100),
    [company_parent_sys_id] VARCHAR(50),
    [company_parent_name] VARCHAR(100),
    [note_count] VARCHAR(50),
    [invoice_status] VARCHAR(50),
    [note_follow_up_user] VARCHAR(50),
    [note_enter_user] VARCHAR(100),
    [patient_first_name] VARCHAR(50),
    [patient_last_name] VARCHAR(50),
    [patient_full_name] VARCHAR(100),
    [patient_gender] VARCHAR(50),
    [patient_category] VARCHAR(50),
    [patient_status] VARCHAR(50),
    [patient_team] VARCHAR(50),
    [patient_service_area] VARCHAR(50),
    [patient_sales_rep] VARCHAR(50),
    [patient_referral_organization] VARCHAR(100),
    [patient_referral_source_contact] VARCHAR(100),
    [patient_primary_rn] VARCHAR(50),
    [next_fu] VARCHAR(50),
    [patient_referral_date] VARCHAR(50),
    [patient_insurance_coordinator] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybuePayable] (
    [patient_full_name] VARCHAR(100),
    [note_patient_mrn] VARCHAR(50),
    [note_entered_date] VARCHAR(50),
    [note_subject] VARCHAR(100),
    [note_body] VARCHAR(4000),
    [note_sys_id] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybuePrecallDOH] (
    [Dispensing ID] VARCHAR(50),
    [Activity Completed Date] VARCHAR(50),
    [What days supply of medication does the patient have on hand at this time?] VARCHAR(50),
    [Enter patient weight in pounds ] VARCHAR(50),
    [Caller notes about days on hand ] VARCHAR(4000),
    [Arrange ship date with caller Enter ship date] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueScheduled] (
    [MRN] VARCHAR(50),
    [Date] VARCHAR(50),
    [Subject] VARCHAR(100),
    [Note] VARCHAR(4000),
    [note_sys_id] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueTestClaims] (
    [patient_full_name] VARCHAR(100),
    [note_patient_mrn] VARCHAR(50),
    [note_entered_date] VARCHAR(50),
    [note_subject] VARCHAR(100),
    [note_body] VARCHAR(4000),
    [note_sys_id] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueDispense] (
    [Rx Written Date] VARCHAR(50),
    [Ship Date] VARCHAR(50),
    [Referral Start Date] VARCHAR(50),
    [Anovo ID] VARCHAR(50),
    [Patient Year of Birth] VARCHAR(50),
    [Refill Indicator] VARCHAR(50),
    [Quantity Dispensed] VARCHAR(50),
    [Record Type] VARCHAR(50),
    [Order Payor Type] VARCHAR(50),
    [Ordering Physician First Name] VARCHAR(50),
    [Ordering Physician NPI] VARCHAR(50),
    [Ordering Physician Last Name] VARCHAR(50),
    [Ordering Physician Address] VARCHAR(200),
    [Ordering Physician City] VARCHAR(50),
    [Ordering Physician State] VARCHAR(50),
    [Ordering Physician Zip] VARCHAR(50),
    [Ordering Physician Phone] VARCHAR(50),
    [Team] VARCHAR(50),
    [Drug Name] VARCHAR(100),
    [Next Delivery Date] VARCHAR(50),
    [Void] VARCHAR(50),
    [Exhaust Date] VARCHAR(50),
    [dispense_therapy_days] VARCHAR(50),
    [Site] VARCHAR(50),
    [order_payor] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybueOrders] (
    [Referral Start Date] VARCHAR(50),
    [Rx Written Date] VARCHAR(50),
    [Ship Date] VARCHAR(50),
    [Anovo ID] VARCHAR(50),
    [Patient Year of Birth] VARCHAR(50),
    [Order Last Event] VARCHAR(50),
    [Order Payor Type] VARCHAR(50),
    [Ordering Physician First Name] VARCHAR(50),
    [Ordering Physician Last Name] VARCHAR(50),
    [Ordering Physician NPI] VARCHAR(50),
    [Ordering Physician Address] VARCHAR(200),
    [Ordering Physician City] VARCHAR(50),
    [Ordering Physician State] VARCHAR(50),
    [Ordering Physician Zip] VARCHAR(50),
    [Ordering Physician Phone] VARCHAR(50),
    [Therapy] VARCHAR(50),
    [Rank] VARCHAR(50),
    [patient_team] VARCHAR(50),
    [Last Event Date] VARCHAR(50),
    [Queue] VARCHAR(100),
    [Payor] VARCHAR(100),
    [Discharge] VARCHAR(50),
    [Referral Source] VARCHAR(50),
    [Next Fill Date] VARCHAR(50),
    [Status] VARCHAR(50),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_DaybuePatients] (
    [mrn] varchar(50),
    [patient_full_name] varchar(100),
    [first_name] varchar(50),
    [last_name] varchar(50),
    [patient_status] varchar(50),
    [gender] varchar(50),
    [patient_date_of_birth] varchar(50),
    [patient_start_of_care_date] varchar(50),
    [patient_referral_date] varchar(50),
    [pat_category] varchar(50),
    [siteno] varchar(50),
    [primary_payer] varchar(100),
    [primary_payer_type] varchar(50),
    [physician_last] varchar(50),
    [physician_first] varchar(50),
    [physician_state] varchar(50),
    [physician_zip] varchar(50),
    [patient_team] varchar(50),
    [patient_language] varchar(50),
    [patient_primary_icd10] varchar(50),
    [patient_primary_icd10_diagnosis] varchar(200),
    [patient_secondary_icd10] varchar(50),
    [patient_secondary_icd10_diagnosis] varchar(200),
    [patient_last_discharge_date] varchar(50),
    [patient_record_created_date] varchar(50),
    [HUB ID] varchar(50),
    [pat_state] varchar(50),
    [secondary_payer] varchar(100),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE [dbo].[STG_HUBCaseStatusReport](
	[Patient ID] [FLOAT] NULL,
	[Encrypted ID] [NVARCHAR](255) NULL,
	[Case ID] [FLOAT] NULL,
	[Case Type] [NVARCHAR](255) NULL,
	[Intake Type] [NVARCHAR](255) NULL,
	[Original Created Date] [DATETIME] NULL,
	[Case Created Date] [DATETIME] NULL,
	[ICD10] [NVARCHAR](255) NULL,
	[Patient Age] [FLOAT] NULL,
	[Patient State] [NVARCHAR](255) NULL,
	[Case Status Type] [NVARCHAR](255) NULL,
	[Case Status] [NVARCHAR](255) NULL,
	[Case Sub Status] [NVARCHAR](255) NULL,
	[Case Status Date] [DATETIME] NULL,
	[Previous Treatment] [NVARCHAR](255) NULL,
	[Clinical Trial ID] [NVARCHAR](255) NULL,
	[Initial Ship Date] [DATETIME] NULL,
	[Last Ship Date] [DATETIME] NULL,
	[Need By Date] [DATETIME] NULL,
	[Pharmacy Need by Date] [DATETIME] NULL,
	[Insurance Name] [NVARCHAR](255) NULL,
	[Primary Medical Insurance] [NVARCHAR](255) NULL,
	[BIN] [NVARCHAR](255) NULL,
	[PCN] [NVARCHAR](255) NULL,
	[Payer Type] [NVARCHAR](255) NULL,
	[Primary PARequired] [NVARCHAR](255) NULL,
	[Primary PAEnd Date] [NVARCHAR](255) NULL,
	[Secondary Payer] [NVARCHAR](255) NULL,
	[Secondary Medical Insurance] [NVARCHAR](255) NULL,
	[Secondary Payer Type] [NVARCHAR](255) NULL,
	[Secondary PARequired] [NVARCHAR](255) NULL,
	[Secondary PAEnd Date] [NVARCHAR](255) NULL,
	[HCP NPI] [NVARCHAR](255) NULL,
	[HCP Name] [NVARCHAR](255) NULL,
	[Facility Name] [NVARCHAR](255) NULL,
	[Facility State] [NVARCHAR](255) NULL,
	[Facility Zip] [NVARCHAR](255) NULL,
	[HIPAA] [NVARCHAR](255) NULL,
	[Marketing] [NVARCHAR](255) NULL,
	[Text] [NVARCHAR](255) NULL,
	[SRS] [NVARCHAR](255) NULL,
	[CM] [NVARCHAR](255) NULL,
	[FSE] [NVARCHAR](255) NULL,
	[PAM] [NVARCHAR](255) NULL,
	[FS] [NVARCHAR](255) NULL,
	[Last Test Claim Date Of Service] [NVARCHAR](255) NULL,
	[Amount Billed] [FLOAT] NULL,
	[Ingredient Cost Paid] [FLOAT] NULL,
	[Total Paid] [FLOAT] NULL,
	[Amount Co Pay] [FLOAT] NULL,
	[Patient Responsibility] [FLOAT] NULL,
	[Reject Code] [NVARCHAR](255) NULL,
	[Reject Description] [NVARCHAR](255) NULL,
	[Import_Date] [DATETIME] NULL
) ON [PRIMARY]
GO

