CREATE TABLE dbo.STG_101_Dispense_Output ([Patient ID] INT,[Rx Date] DATE,[Dispensed Date] DATE
				,[Quantity Dispensed] INT,[Days Supply] INT,[Refill No] INT,[Drug Name] VARCHAR(255)
				,[Refills Allowed] INT,[Refills Remaining] INT,[Primary Payer Type] VARCHAR(255)
				,[HCP Last] VARCHAR(255),[HCP First] VARCHAR(255),[HCP Group] VARCHAR(255)
				,[HCP Address] VARCHAR(1000),[HCP City] VARCHAR(255),[HCP State] VARCHAR(10)
				,[HC Zip] VARCHAR(20),[HCP Phone] VARCHAR(20),[Bridge Shipment] VARCHAR(50),[Patient Pay] DECIMAL(18,2)
				)