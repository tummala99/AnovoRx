	USE Anovo_Reports

	SELECT @@ServerName

	/***************************/
	SELECT * FROM Anovo_Stage.dbo.ShipmentsTracking WHERE ticket_shipping_method = 'FedEx'
	SELECT * FROM Anovo_Stage.dbo.ShipmentsTracking WHERE ticket_patient_mrn = 200221 
	AND ticket_shipping_tracking_number = '084196215016720'
	SELECT * FROM [dbo].[DwhShipmentsTrackingHistory] 
	 WHERE TrackingNumber = '084196215016720' ORDER BY EventDateTime

	SELECT TOP 100 * FROM [dbo].[DwhShipmentsTracking]
	SELECT  * FROM [dbo].[DwhShipmentsTrackingHistory]

	SELECT A.ticket_patient_mrn AS PatientId
		 , A.ticket_number
		 , A.ticket_shipping_tracking_number AS TrackingNumber
		 , A.ticket_therapy AS Therapy
		 , A.ticket_ship_to_name AS ShipToName
		 , A.ticket_ship_to_address AS ShipAddress
		 , A.ticket_ship_to_city AS ShipCity 
		 , A.ticket_ship_to_state AS ShipState
		 , A.ticket_ship_to_zip AS ShipZip
		 , A.[Status] AS CurrentStatus
		 , A.StatusDescription
		 , A.StatusDate
		 , B.EventDateTime
		 , B.EventDescription
		 , B.ExceptionCode
		 , B.ExceptionDescription
		 , B.[StreetLines]
		 , B.[City]
		 , B.[StateOrProvinceCode]
		 , B.[PostalCode]
		 , B.[CountryCode]
		 --, B.[Residential]
		 , B.[CountryName]
		 , B.[LocationId]
		 , B.[LocationType]
		 , B.[DerivedStatusCode]
		 , B.[DerivedStatus]		 
		 , A.EstimatedDeliveryDate
	  FROM [dbo].[DwhShipmentsTracking] A
	  INNER JOIN [dbo].[DwhShipmentsTrackingHistory] B
	    ON A.ShipmentsTrackingId = B.ShipmentsTrackingId
	   AND A.ticket_shipping_tracking_number = B.TrackingNumber
	 WHERE ticket_shipping_method = 'FedEx'
	 ORDER BY A.ticket_patient_mrn,A.ticket_number, A.StatusDate, B.EventDateTime
	    --

	SELECT COUNT(1) FROM [dbo].[DwhShipmentsTracking] -- 566652
	SELECT COUNT(1) FROM [dbo].[DwhShipmentsTrackingHistory] -- 160
	
	--ALTER TABLE DwhShipmentsTracking 
	--  ADD [Status] VARCHAR(500),[StatusCode] VARCHAR(50),StatusDescription VARCHAR(1000),StatusDate DATETIME
	--    , EstimatedDeliveryDate DateTime
	--	, JsonResponse NVARCHAR(max)
	--CREATE TABLE [dbo].[DwhShipmentsTrackingHistory](
 --     [Id] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
 --     [ShipmentsTrackingId] [INT] NOT NULL,
 --     [TrackingNumber] [NVARCHAR](255) NULL,
 --     [EventDateTime] [DATETIMEOFFSET](7) NOT NULL,
 --     [EventType] [NVARCHAR](10) NULL,
 --     [EventDescription] [NVARCHAR](255) NULL,
 --     [ExceptionCode] [NVARCHAR](10) NULL,
 --     [ExceptionDescription] [NVARCHAR](255) NULL,
 --     [StreetLines] [NVARCHAR](255) NULL,
 --     [City] [NVARCHAR](100) NULL,
 --     [StateOrProvinceCode] [NVARCHAR](10) NULL,
 --     [PostalCode] [NVARCHAR](20) NULL,
 --     [CountryCode] [NVARCHAR](10) NULL,
 --     [Residential] [BIT] NULL,
 --     [CountryName] [NVARCHAR](100) NULL,
 --     [LocationId] [NVARCHAR](20) NULL,
 --     [LocationType] [NVARCHAR](50) NULL,
 --     [DerivedStatusCode] [NVARCHAR](10) NULL,
 --     [DerivedStatus] [NVARCHAR](50) NULL)

	SELECT ticket_number,
		   COUNT(1)
	  FROM Anovo_Stage.dbo.ShipmentsTracking
	 GROUP BY ticket_number
	HAVING COUNT(1) > 1;

	/***************************/
	SELECT TOP 100 * FROM Anovo_Stage.dbo.Patient 
	SELECT TOP 100 * FROM Anovo_Stage.dbo.PatientAddress 

	SELECT TOP 100 * FROM [dbo].[DwhPatient]
	SELECT TOP 100 * FROM [dbo].[DwhPatientStatusReport] WHERE StatusType = 'Active'
	
	
	SELECT TOP 100 * FROM [dbo].[DwhShipments]
	SELECT TOP 100 * FROM Anovo_Stage.dbo.VwOrdersLastStatus
	SELECT TOP 100 * FROM Anovo_Stage.dbo.Orders  
	/****************************/



	
	SELECT * FROM dbo.DwhPatientTextConsentReport
	
	


	DECLARE @LoadDate DATE 
	--SET @LoadDate = DATEADD(DAY,-15,GETDATE())
	
	SELECT MRN,Answer ,[Date]
	  FROM 
		 (
		SELECT patientId AS MRN 		 
			 --, CONVERT(VARCHAR(10),EnteredDdate,101) +' '+ CONVERT(VARCHAR(10),EnteredDdate,108) AS [EnteredDate]
			 , Answer		 
			 , CONVERT(VARCHAR(10),ModifiedOn,101) +' '+ CONVERT(VARCHAR(10),ModifiedOn,108) AS [Date]
			 , ROW_NUMBER() OVER (PARTITION BY patientId ORDER BY ModifiedOn DESC) AS RowId
			 --, Question			 
		  FROM dbo.DwhPatientAssessments
		 WHERE title = 'Text Messaging Authorization'
		   AND [Status] = 'Complete'
		   AND QuestionNumber = 1
		   --AND (CAST(ModifiedOn AS DATE) >= @LoadDate OR @LoadDate IS NULL)
		) AS T
	WHERE T.RowId = 1 -- 3387

SELECT patientId,
       EnteredDdate,
       Answer,
       ModifiedOn
  FROM dbo.DwhPatientAssessments
 WHERE title          = 'Text Messaging Authorization'
   AND Status         = 'Complete'
   AND QuestionNumber = 1;

	SELECT COUNT(1) FROM Anovo_Reports.[dbo].[DwhPatientAssessments] (NOLOCK)
	
	

	SELECT patientId,AssessmentId,COUNT(1) 
	  FROM Anovo_Reports.[dbo].[DwhPatientAssessments]
	 GROUP BY patientId,AssessmentId
	 HAVING COUNT(1) > 10
	 ORDER BY patientId,AssessmentId


	 --TRUNCATE TABLE Anovo_Reports.[dbo].[DwhPatientAssessments]
--SELECT COUNT(1) FROM [dbo].[DwhPatientAssessments]
	SELECT TOP 1000 * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] 
	 WHERE 1 =1--PatientId = 200285
	   --AND [Status] = 'Complete'
	   --AND Category = 'General'
	   AND AssessmentId = 296792 --31955--153989
	 ORDER BY AssessmentId,QuestionId--QuestionNumber
	 
	 SELECT * FROM Anovo_Stage.[dbo].[ProcessLog]

	 SELECT TOP 1000 AssessmentId,QuestionId,COUNT(1) FROM Anovo_Stage.[dbo].[PatientAssessments] 
	  GROUP BY AssessmentId,QuestionId
	  HAVING COUNT(1) > 1

	  SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE PatientId = 212951 ORDER BY AssessmentId,QuestionId
	  SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE PatientId = 212951 AND AssessmentId = 217698  ORDER BY AssessmentId,QuestionId,PatientAssessmentId
	  SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE PatientId = 212951 AND AssessmentId = 156097  ORDER BY AssessmentId,QuestionId,PatientAssessmentId
	  SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE AssessmentId = 214007 ORDER BY AssessmentId,QuestionId

	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 212951 ORDER BY AssessmentId,QuestionOrder,PatientAssessmentId
	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 212951 AND AssessmentId = 214007 ORDER BY AssessmentId,QuestionOrder,PatientAssessmentId
	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 212951 AND AssessmentId = 217698 ORDER BY AssessmentId,QuestionOrder,PatientAssessmentId
	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 212951 AND AssessmentId = 156097 ORDER BY AssessmentId,QuestionOrder,PatientAssessmentId

	  SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE PatientId = 231315 AND AssessmentId = 318109 ORDER BY AssessmentId,QuestionId
	  SELECT TOP 1000 * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 231315 AND AssessmentId = 318109
	  ORDER BY AssessmentId,QuestionId

	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 200223--209233
	   ORDER BY AssessmentId,QuestionId
	  SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 212951--200223--209233
	     AND AssessmentId IN (116325,156097,217698)--(2717,4143,8849,10271)
		 --AND Question = 'Delivery Exception'
	   ORDER BY AssessmentId,QuestionOrder

	SELECT @@Version
	SELECT * FROM Anovo_Reports.[dbo].[DwhPatientAssessments] WHERE PatientId = 200202 
	ORDER BY AssessmentId,QuestionNumber
	SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] WHERE PatientId = 200202 
	ORDER BY AssessmentId,QuestionNumber

		--DROP TABLE Anovo_Reports.[dbo].[DwhPatientAssessments]	
			SELECT *
				 , (CAST(FORMAT(QuestionNumber,'00') AS VARCHAR(100)) +'.'+ CAST(ROW_NUMBER() OVER(PARTITION BY AssessmentId,QuestionNumber ORDER BY QuestionNumber) AS VARCHAR(100))) AS QuestionOrder
				 , RANK() OVER(PARTITION BY AssessmentId ORDER BY QuestionNumber) AS SNo
				 , DENSE_RANK() OVER(PARTITION BY AssessmentId ORDER BY QuestionNumber) AS SNo
			  FROM
			(
			SELECT PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
							,Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn
			  FROM
				(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY AssessmentId,QuestionId,AnswerId ORDER BY ModifiedOn DESC) AS RowId 
				  FROM Anovo_Stage.[dbo].[PatientAssessments] --2025-05-27 17:26:08.243
				  WHERE AssessmentId IN (116325,156097,217698)--(8849,10271,296792)
				    AND Question = 'Patient- Authentication'
				) AS T					 
			 WHERE T.RowId = 1			 
			 --ORDER BY ModifiedOn
			 ) AS T
			 ORDER BY T.AssessmentId,QuestionOrder
			 


	--SELECT * FROM Anovo_Stage.[dbo].[PatientAssessments] 
	-- WHERE patientId = 204675 AND AssessmentId = 75682 
	--   AND PatientAssessmentId >= 4488474
	-- ORDER BY AssessmentId,QuestionId

	SELECT Max(ProcessId) FROM Anovo_Reports.DBO.DwhDbLog
	SELECT * FROM Anovo_Reports.dbo.DwhProcessLog WHERE ProcessLogId = 635
	SELECT * FROM Anovo_Reports.DBO.DwhDbLog WHERE ProcessName = 'prcDwhLoadPatientAssessmentData'
	SELECT * FROM Anovo_Reports.DBO.DwhDbLog WHERE ProcessName = 'prcDwhLoadHcpData'
	SELECT * FROM Anovo_Reports.DBO.DwhDbLog WHERE LogType = 'ERROR'

	SELECT SUSER_NAME() 

[dbo].[prcDwhLogging]
[dbo].[prcDwhLoggingEtl]

	SELECT COUNT(1) FROM Anovo_Reports.[dbo].[DwhPatientAssessments] (NOLOCK) --4486129