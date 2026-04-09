USE [Anovo_Reports]
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'PatientAssessmentsProd')
	DROP SYNONYM [dbo].[PatientAssessmentsProd]
GO

/****** Object:  Synonym [dbo].[HcpProd]    Script Date: 04-06-2025 12:19:36 ******/
CREATE SYNONYM [dbo].[PatientAssessmentsProd] FOR Anovo_Stage.[dbo].[PatientAssessments]
GO

--SELECT TOP 100 FROM [dbo].[PatientAssessmentsProd]
