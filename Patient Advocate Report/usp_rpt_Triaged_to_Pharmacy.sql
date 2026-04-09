CREATE PROCEDURE [dbo].[usp_rpt_Triaged_to_Pharmacy]
AS
/*
	Purpose: Consolidate and generate Dashboard Review Report data
	
	EXEC dbo.[usp_rpt_Triaged_to_Pharmacy]
	--SELECT * FROM [dbo].[STG_HUBCaseStatusReport]
	--SELECT * FROM dbo.rpt_100_Dashboard_Review			
*/
BEGIN
    SET NOCOUNT ON;

	DELETE 
	  FROM [dbo].[STG_HUBCaseStatusReport] 
	 WHERE ISNULL([Patient ID],'') = ''

    IF OBJECT_ID('dbo.rpt_1000_Triaged_to_Pharmacy') IS NOT NULL
    BEGIN
        TRUNCATE TABLE dbo.rpt_1000_Triaged_to_Pharmacy;
    END
    ELSE
    BEGIN

	CREATE TABLE dbo.rpt_1000_Triaged_to_Pharmacy(ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT,[Patient_Status] VARCHAR(255) ,[Order Status] VARCHAR(255),Payer VARCHAR(255) 
				, [Queue] VARCHAR(255),[Last Event] VARCHAR(255),[Last Event Date] DATE,[HUB Status] VARCHAR(255),[Last Fill] DATE
				, [Next Fill] DATE,[Need by Date] DATE,Category VARCHAR(255),[Review Notes] VARCHAR(4000)
			)       
    END;

    -- Insert the data
    INSERT INTO dbo.rpt_1000_Triaged_to_Pharmacy  ([Name] , [MRN] , [HUB ID] ,[Patient_Status]  ,[Order Status] ,Payer  
				 ,[Queue] ,[Last Event] ,[Last Event Date],[HUB Status] ,[Last Fill]
				 , [Next Fill] ,[Need by Date] ,Category ,[Review Notes]
			)
        
	SELECT DR.[Name]
		 , DR.MRN
		 , DR.[HUB ID]
		 , DR.patient_status
		 , DR.[Order Status]
		 , DR.Payer
		 , DR.[Queue]
		 , DR.[Last Event]
		 , DR.[Last Event Date]
		 , CSR.[Case Status] AS [HUB Status]
		 , DR.[Last Fill]
		 , DR.[Next Fill]
		 , DR.[Need by Date]
		 , DR.Category
		 , DR.[Review Notes]
	  FROM [dbo].[STG_HUBCaseStatusReport] CSR
	  LEFT JOIN dbo.rpt_100_Dashboard_Review AS DR 
	    ON CSR.[Patient ID] = DR.[HUB ID]
	 WHERE (CSR.[Case Status] = 'Triaged to SP'
		 OR CSR.[Case Status] = 'Triaged to PAP'
		 OR CSR.[Case Status] = 'Triaged to Bridge'
		)

		
	
END
