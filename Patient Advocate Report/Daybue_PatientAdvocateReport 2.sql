USE TherapyAdvocateDaybueDev
SELECT @@version

SELECT * FROM dbo.[STG_100_Dashboard_Review] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_200_Late_Shipment] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_300_Early_Shipment] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_400_Days_to_Exhaust] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_500_No_Go] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_600_Scheduled] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_700_Dose_Change] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_800_New_Rx] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_900_Need_Rx] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_1000_Triaged_to_Pharmacy] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_1100_DC] WHERE MRN IS NULL
SELECT * FROM dbo.[STG_Afternoon_Review] WHERE MRN IS NULL
SELECT * FROM dbo.STG_HUBCaseStatusReport

SELECT MRN,COUNT(1) 
  FROM dbo.[STG_100_Dashboard_Review] 
 GROUP BY MRN
 HAVING COUNT(1) > 1

/*
--Patient Advocate Report 
-- Therapy Advocate Daybue

	TRUNCATE TABLE dbo.[STG_100_Dashboard_Review];
	TRUNCATE TABLE dbo.[STG_200_Late_Shipment];
	TRUNCATE TABLE dbo.[STG_300_Early_Shipment];
	TRUNCATE TABLE dbo.[STG_400_Days_to_Exhaust];
	TRUNCATE TABLE dbo.[STG_500_No_Go];
	TRUNCATE TABLE dbo.[STG_600_Scheduled];
	TRUNCATE TABLE dbo.[STG_700_Dose_Change];
	TRUNCATE TABLE dbo.[STG_800_New_Rx];
	TRUNCATE TABLE dbo.[STG_900_Need_Rx];
	TRUNCATE TABLE dbo.[STG_1000_Triaged_to_Pharmacy];
	TRUNCATE TABLE dbo.[STG_1100_DC];
	TRUNCATE TABLE dbo.[STG_Afternoon_Review];	


	DROP TABLE dbo.[STG_100_Dashboard_Review]
	DROP TABLE dbo.[STG_200_Late_Shipment]
	DROP TABLE dbo.[STG_300_Early_Shipment]
	DROP TABLE dbo.[STG_400_Days_to_Exhaust]
	DROP TABLE dbo.[STG_500_No_Go] 
	DROP TABLE dbo.[STG_600_Scheduled]
	DROP TABLE dbo.[STG_700_Dose_Change]
	DROP TABLE dbo.[STG_800_New_Rx]
	DROP TABLE dbo.[STG_900_Need_Rx] 
	DROP TABLE dbo.[STG_1000_Triaged_to_Pharmacy]
	DROP TABLE dbo.[STG_1100_DC]
	DROP TABLE dbo.[STG_Afternoon_Review];
*/

CREATE TABLE dbo.[STG_100_Dashboard_Review] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [patient_status] NVARCHAR(255),
    [Order Status] NVARCHAR(255),
    [Payer] NVARCHAR(255),
    [Secondary] NVARCHAR(255),
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_200_Late_Shipment] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_300_Early_Shipment] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Queue] NVARCHAR(255),
    [Last Event Date] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Payer] NVARCHAR(255),
    [Secondary] NVARCHAR(255),
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
    [Test Claim] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_400_Days_to_Exhaust] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_500_No_Go] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Payer] NVARCHAR(255),
    [No Go Date] DATETIME,
    [Subject] NVARCHAR(255),
    [No Go Note] NVARCHAR(255),
    [Resolved Date] DATETIME,
    [Resolved] NVARCHAR(255),
    [Resolved Note] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)


CREATE TABLE dbo.[STG_600_Scheduled] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Queue] NVARCHAR(255),
    [Payer] NVARCHAR(255),
    [Secondary] NVARCHAR(255),
    [Last Fill] DATETIME,
    [Scheduled] DATETIME,
    [Need by Date] DATETIME,
    [Precall Completed On] DATETIME,
    [DOH] FLOAT,
    [Exhaust Per Therigy] DATETIME,
    [DOH On Ship Date] FLOAT,
    [Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_700_Dose_Change] (
    [Patient Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Last Dispense Orig Date] DATETIME,
    [Last Dispense Order] NVARCHAR(255),
    [New Order Date] DATETIME,
    [New Order] NVARCHAR(255),
    [Dose Change] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_800_New_Rx] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Payer] NVARCHAR(255),
    [Secondary] NVARCHAR(255),
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_900_Need_Rx] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [Last Fill] DATETIME,
    [Next Fill] DATETIME,
    [Need by Date] DATETIME,
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_1000_Triaged_to_Pharmacy] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [patient_status] NVARCHAR(255),
    [Order Status] NVARCHAR(255),
    [Payer] NVARCHAR(255),
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] DATETIME,
    [HUB Status] NVARCHAR(255),
    [Last Fill] NVARCHAR(255),
    [Next Fill] DATETIME,
    [Need by Date] NVARCHAR(255),
    [Category] NVARCHAR(255),
    [Review Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)
CREATE TABLE dbo.[STG_1100_DC] (
    [Name] NVARCHAR(255),
    [MRN] FLOAT,
    [HUB ID] FLOAT,
    [patient_status] NVARCHAR(255),
    [Order Status] NVARCHAR(255),
    [Discharge Date] DATETIME,
    [Discharge] NVARCHAR(255),
    [Discharge Note] NVARCHAR(MAX),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)

CREATE TABLE dbo.[STG_Afternoon_Review] (
    [Name] NVARCHAR(255),
    [MRN] NVARCHAR(255),
    [HUB ID] NVARCHAR(255),
    [Queue] NVARCHAR(255),
    [Last Event] NVARCHAR(255),
    [Last Event Date] NVARCHAR(255),
    [Last Ship Date] NVARCHAR(255),
    [Next Fill] NVARCHAR(255),
    [Need By Date] NVARCHAR(255),
    [Category] NVARCHAR(255),
    [Follow Up Notes] NVARCHAR(255),
	[Import_Date] [DATETIME] NULL DEFAULT GETDATE()
)



--SELECT TOP 1000 * FROM Anovo_Reports.dbo.DwhPatientAssessments WHERE patientId = 218074 --IN (224616)--(211202)
--SELECT * FROM Anovo_Reports.dbo.DwhPatient WHERE PatientId = --224616
--SELECT DISTINCT patientId FROM Anovo_Reports.dbo.DwhPatientAssessments
--SELECT * FROM IncrelexDB.[dbo].[STG_0046MultipleShips_Output]
--SELECT * FROM IncrelexDB.[dbo].[STG_101_Dispense_Output]