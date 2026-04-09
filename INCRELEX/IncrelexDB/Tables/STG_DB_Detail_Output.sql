
CREATE TABLE dbo.STG_DB_Detail_Output (MRN INT,[Patient ID] INT,[Type] VARCHAR(255),[Referral Source Org] VARCHAR(255),[Creation Date] DATE,[Year of Birth] INT,
		[ICD-10] VARCHAR(255),[Status Type] VARCHAR(255),[Order Last Event Status] VARCHAR(255),[Status Date] DATE
		,[Patient Aging Days] INT,[Status Aging Days] INT,[Initial Dispense Date] DATE,[Initial Dispense Type] VARCHAR(255)
		,[Last Dispense Date] DATE,[Last Dispense Type] VARCHAR(255),[Therapy Days] INT,[Exhaust Date] DATE,[Next Fill Date] DATE
		,[HCP First] VARCHAR(255),[HCP Last] VARCHAR(255),[HCP NPI] VARCHAR(255),[HCP Address] VARCHAR(1000),[HCP City] VARCHAR(255)
		,[HCP State] VARCHAR(10),[HCP Zip] VARCHAR(20),[HCP Phone] VARCHAR(50),[Payer Type] VARCHAR(255),Payer VARCHAR(255)
		,[PA/Appeal Status] VARCHAR(255),[PA/Appeal Status Date] DATE
		,[Secondary Payer Type] VARCHAR(255),[Secondary Payer] VARCHAR(255),[Secondary PA/Appeal Status] VARCHAR(255),[Secondary PA/Appeal Status Date] DATE
		)