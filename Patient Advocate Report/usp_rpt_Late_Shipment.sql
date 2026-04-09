IF (OBJECT_ID('dbo.usp_rpt_Late_Shipment') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Late_Shipment
GO

CREATE PROCEDURE dbo.usp_rpt_Late_Shipment
AS
/*
	Purpose: Generate Late_Shipment Report data
	
	EXEC dbo.usp_rpt_Late_Shipment

*/
BEGIN
	SET NOCOUNT ON

	/************************************************
	************_200_Late_Shipment*******************
	*************************************************/
	IF(OBJECT_ID('dbo.rpt_200_Late_Shipment') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_200_Late_Shipment
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_200_Late_Shipment(ID INT IDENTITY(1,1)				
				, [Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT,[Queue] VARCHAR(255),[Last Event] VARCHAR(255),[Last Event Date] DATE,[Last Fill] DATE
				, [Next Fill] DATE,DATE,Category VARCHAR(255),[Review Notes] VARCHAR(4000)
			)
	END

	INSERT INTO dbo.rpt_200_Late_Shipment([Name] , [MRN] , [HUB ID] ,[Queue] ,[Last Event] ,[Last Event Date] ,[Last Fill]
				 , [Next Fill] ,[Need by Date] ,Category ,[Review Notes])
	SELECT [Name]
		 , MRN
		 , [HUB ID]
		 , [Queue]
		 , [Last Event]
		 , [Last Event Date]
		 , [Last Fill]
		 , [Next Fill]
		 , [Need by Date]
		 , Category
		 , [Review Notes]
	  FROM dbo.rpt_100_Dashboard_Review
	 WHERE Category = 'Late Shipment'
	 ORDER BY MRN
END
       