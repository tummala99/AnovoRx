
	SELECT 'SELECT * FROM ' +[name] FROM sys.objects WHERE [type] = N'U'

use Anovo_Pyros



	SELECT * FROM CprStatuses
	SELECT * FROM PyrosStatuses
	SELECT * FROM XrefStatuses
	SELECT * FROM DbParameters
	SELECT * FROM SpStatusDispenseFile
	SELECT * FROM wsWholesaleSAP
	SELECT * FROM wsDispenseFile
	SELECT * FROM ProcessLog
	SELECT * FROM DbLog

/*******************************************/
USE Anovo_Reports

	SELECT * FROM DWHShipmentsWip
	SELECT * FROM DWHOrtfPtsRx
	SELECT * FROM DwhVigRxOrtf
	SELECT * FROM DWHOrderLastEventMapping
	SELECT * FROM DwhHcp
	SELECT * FROM DwhPatient
	SELECT * FROM DwhPatientNotes
	SELECT * FROM DwhInsurance
	SELECT * FROM DwhManufacturer
	SELECT * FROM DwhTherapy
	SELECT * FROM DwhManufacturerTherapy
	SELECT * FROM DwhProcessLog
	SELECT * FROM DwhOrders
	SELECT * FROM DwhShipments
	SELECT * FROM DwhDbLog
	SELECT * FROM DwhPatientStatusReport
	SELECT * FROM DwhPatientTherapy
	SELECT * FROM DwhPatientInsurance
	SELECT * FROM DwhDbParameters
	SELECT * FROM DwhPaAppealMappings
	SELECT * FROM DwhPatientStatusDashboard
	SELECT * FROM DwhBasePatientStatus
	SELECT * FROM ORTFPatients
	SELECT * FROM ORTFPharmacy

/*******************************************/
USE [Anovo_Stage]

	SELECT * FROM PatientNcpdp
	SELECT * FROM PatientNcpdpResponse
	SELECT * FROM PatientInvoice
	SELECT * FROM Profitability
	SELECT * FROM PatientNotes
	SELECT * FROM Insurance
	SELECT * FROM ProcessLog
	SELECT * FROM OrderLastEventMapping
	SELECT * FROM PatientPhones
	SELECT * FROM Therapy
	SELECT * FROM Shipments
	SELECT * FROM ShipmentsWip
	SELECT * FROM DbLog
	SELECT * FROM Patient
	SELECT * FROM PatientAddress
	SELECT * FROM PatientStatusReport
	SELECT * FROM Hcp
	SELECT * FROM PatientTherapy
	SELECT * FROM PatientStatus
	SELECT * FROM PatientInsurance
	SELECT * FROM DbParameters
	SELECT * FROM PatientContacts
	SELECT * FROM Orders
	SELECT * FROM QueueMove
	SELECT * FROM Manufacturer
	SELECT * FROM ManufacturerTherapy
	SELECT * FROM InsVeriAuth
	SELECT * FROM Insver
	SELECT * FROM PatientAssessments
