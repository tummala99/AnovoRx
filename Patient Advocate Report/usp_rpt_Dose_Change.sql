IF (OBJECT_ID('dbo.usp_rpt_Dose_Change') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_Dose_Change
GO

CREATE PROCEDURE dbo.usp_rpt_Dose_Change
AS
/*
	Purpose: Generate Schedule Report data
	
	EXEC dbo.usp_rpt_Dose_Change
	
*/
BEGIN
	SET NOCOUNT ON

	/*******************************************************
	--------- 701 New Orders Max -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#701NewOrdersMax') IS NOT NULL)
		DROP TABLE #701NewOrdersMax

	SELECT [Patient Name]
		 , MRN
		 , MAX([Order Date]) AS [MaxOfOrder Date]
		 , [Order Description]
	  INTO #701NewOrdersMax
	  FROM dbo.[STG_DaybueNewOrders]
	 GROUP BY [Patient Name],MRN,[Order Description]
	 ORDER BY MAX([Order Date]) DESC;
	
	--SELECT MRN,COUNT(1) FROM #701NewOrdersMax GROUP BY MRN HAVING COUNT(1) > 1
	--SELECT * FROM #701NewOrdersMax WHERE MRN = 242407
	
	/*******************************************************
	--------- 702 Dispense Max -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#702DispenseMax') IS NOT NULL)
		DROP TABLE #702DispenseMax

	SELECT mrn
		 , order_original_rx_date
		 , dispense_date
		 , order_description
	  INTO #702DispenseMax
	  FROM dbo.STG_DaybueDoseChange	
	 ORDER BY dispense_date DESC;

	 --SELECT MRN,COUNT(1) FROM #702DispenseMax GROUP BY MRN HAVING COUNT(1) > 1
	 --SELECT * FROM #702DispenseMax WHERE MRN = 240333
	/*******************************************************
	--------- 703 Dose Change -----------------
	********************************************************/
	IF(OBJECT_ID('tempdb..#703DoseChange') IS NOT NULL)
		DROP TABLE #703DoseChange

	SELECT A.[Patient Name]
		 , A.MRN
		 , MAX(B.order_original_rx_date) AS [Last Dispense Orig Date]
		 , B.order_description AS [Last Dispense Order]
		 , A.[MaxOfOrder Date] AS [New Order Date]
		 , A.[Order Description] AS [New Order]
		 , IIF(A.[order description] = B.[order_description],	'no dose change',	'dose change'	) AS [Dose Change]
	  INTO #703DoseChange
	  FROM #701NewOrdersMax A
	 INNER JOIN #702DispenseMax B 
	    ON A.MRN = B.mrn
	 WHERE A.[order description] <> B.[order_description]
	 GROUP BY A.[Patient Name]
		 , A.MRN
		 , B.order_description
		 , A.[MaxOfOrder Date]
		 , A.[Order Description]
		 , IIF(A.[order description] = B.[order_description],'no dose change',	'dose change')
	--HAVING	((IIf(	A.[order description] = B.[order_description],	'no dose change','dose change')) <> 'no dose change')
	 ORDER BY A.[MaxOfOrder Date] DESC;

	--SELECT * FROM #703DoseChange

	/*******************************************************
	--------- _700_Dose_Change -----------------
	********************************************************/
	IF(OBJECT_ID('dbo.rpt_700_Dose_Change') IS NOT NULL)
		TRUNCATE TABLE dbo.rpt_700_Dose_Change
	ELSE
	BEGIN
		CREATE TABLE dbo.rpt_700_Dose_Change (ID INT IDENTITY(1,1)				
				, [Patient Name] VARCHAR(255), [MRN] BIGINT, [HUB ID] BIGINT ,[Last Dispense Orig Date] DATE
				, [Last Dispense Order] VARCHAR(255), [New Order Date] DATE, [New Order] VARCHAR(255),[Dose Change] VARCHAR(255))
				
	END
	
	INSERT INTO dbo.rpt_700_Dose_Change ([Patient Name] , [MRN] , [HUB ID],[Last Dispense Orig Date] 
				 , [Last Dispense Order], [New Order Date], [New Order] ,[Dose Change] 				 
			)	

	SELECT A.[Patient Name]
		 , A.MRN
		 , B.[HUB ID]
		 , CAST(NULLIF(A.[Last Dispense Orig Date],'') AS DATE) AS [Last Dispense Orig Date]
		 , A.[Last Dispense Order]
		 , CAST(NULLIF(A.[New Order Date],'') AS DATE) AS [New Order Date]
		 , A.[New Order]
		 , A.[Dose Change]
	  FROM #703DoseChange A
	  LEFT JOIN dbo.rpt_100_Dashboard_Review B 
	    ON A.MRN = B.MRN
	 ORDER BY A.[New Order Date] DESC;
	
	
END