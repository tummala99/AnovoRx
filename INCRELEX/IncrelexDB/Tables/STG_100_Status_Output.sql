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