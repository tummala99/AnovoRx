USE IncrelexDev
GO

IF (OBJECT_ID('dbo.usp_rpt_Dispense') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Dispense
GO

CREATE PROCEDURE dbo.usp_rpt_Dispense
AS
/*
	Purpose: Consolidate and generate Patient Dispense Report data
	
	EXEC dbo.usp_rpt_Status

*/
BEGIN
	/****************101_Dispense*************************/
	IF(OBJECT_ID('dbo.STG_101_Dispense_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_101_Dispense_Output
	ELSE
	BEGIN
		CREATE TABLE dbo.STG_101_Dispense_Output ([Patient ID] INT,[Rx Date] DATE,[Dispensed Date] DATE
				,[Quantity Dispensed] INT,[Days Supply] INT,[Refill No] INT,[Drug Name] VARCHAR(255)
				,[Refills Allowed] INT,[Refills Remaining] INT,[Primary Payer Type] VARCHAR(255)
				,[HCP Last] VARCHAR(255),[HCP First] VARCHAR(255),[HCP Group] VARCHAR(255)
				,[HCP Address] VARCHAR(1000),[HCP City] VARCHAR(255),[HCP State] VARCHAR(10)
				,[HC Zip] VARCHAR(20),[HCP Phone] VARCHAR(20),[Bridge Shipment] VARCHAR(50),[Patient Pay] DECIMAL(18,2)
				)
	END	

	INSERT INTO dbo.STG_101_Dispense_Output ([Patient ID],[Rx Date],[Dispensed Date],[Quantity Dispensed],[Days Supply],[Refill No],[Drug Name],[Refills Allowed]
				,[Refills Remaining],[Primary Payer Type],[HCP Last],[HCP First],[HCP Group],[HCP Address],[HCP City],[HCP State]
				,[HC Zip],[HCP Phone],[Bridge Shipment],[Patient Pay]
				)
	SELECT DISTINCT D.[mrn]-40119 AS [Patient ID]
		 , D.order_original_rx_date AS [Rx Date]
		 , D.dispense_date AS [Dispensed Date]
		 , D.bagsdisp AS [Quantity Dispensed]
		 , D.dispense_days_supply AS [Days Supply]
		 , D.refillnum AS [Refill No]
		 , D.line9 AS [Drug Name]
		 , D.dispense_refills_allowed AS [Refills Allowed]
		 , D.dispense_refills_remaining AS [Refills Remaining]
		 , NCP.primary_payor_type AS [Primary Payer Type]
		 , D.physician_last AS [HCP Last]
		 , D.physician_first AS [HCP First]
		 , D.physician_practice AS [HCP Group]
		 , D.physician_address AS [HCP Address]
		 , D.physician_city AS [HCP City]
		 , D.physician_state AS [HCP State]
		 , D.physician_zip AS [HC Zip]
		 , D.physician_phone AS [HCP Phone]
		 , IIf(D.[line9] Like '%Starter','Yes','') AS [Bridge Shipment]
		 , PP.[Patient Pay]
	FROM dbo.STG_Dispense D
	LEFT JOIN (
				SELECT DISTINCT patient_mrn
					 , ncpdp_date_filled_timestamp
					 , IIf([secondary_payor_type] Is Not Null,[ncpdp_other_secondary_copay_expected],[ncpdp_patient_copay_expected]) AS [Patient Pay]
					 , ncpdp_rx_description
				  FROM dbo.STG_NCPDP
			 ) PP
	  ON (D.mrn = PP.patient_mrn) 
	 AND (D.dispense_date = PP.ncpdp_date_filled_timestamp) 
	 AND (D.line9 = PP.ncpdp_rx_description) 
	LEFT JOIN dbo.STG_NCPDP NCP 
	  ON (D.mrn = NCP.patient_mrn) 
	 AND (D.dispense_date = NCP.ncpdp_invoice_date_of_service_timestamp)
	WHERE (((D.line9) Like '%Increlex%'))
	
	--SELECT * FROM dbo.STG_101_Dispense_Output
END