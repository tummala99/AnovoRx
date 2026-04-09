	USE Anovo_Reports_AllSites	
	USE Anovo_Reports_Test
--	SELECT TOP 100 * FROM DwhShipments

--	SELECT SUSER_NAME();
--	--SELECT CURRENT_USER();
--	SELECT HOST_NAME();
--	SELECT APP_NAME();


	

--CREATE TABLE [dbo].[DwhDataFeedFileGenerationList](
--	[Id] [INT] IDENTITY(1,1) NOT NULL,
--	[DataFileName] VARCHAR(255) NULL,
--	[SQLStatement] NVARCHAR(MAX) NULL,
--	[Delimiter] VARCHAR(10) NULL,
--	[CreatedDate] DATETIME NULL DEFAULT (GETDATE()) ,
--	[CreatedBy] INT NULL,
--	[ModifiedDate] DATETIME NULL,
--	[ModifiedBy] INT NULL,
--	[GroupName] VARCHAR(255) NULL,
--	[Frequency] VARCHAR(255) NULL,
--	[LastFeedRunDate] DATETIME NULL,
--	[IsActive] BIT NULL
--) 
--GO


--D:\Anovo\Projects\JiraTasks\IN-31\Ascendis\Destination
	SELECT * FROM [dbo].[DwhDataFeedFileGenerationList] WHERE IsActive = 1 AND GroupName = 'AscendisPharmaEndocrinology' AND Frequency = 'DAILY'
	SELECT DataFileName,SQLStatement,Delimiter FROM dbo.[DwhDataFeedFileGenerationList] WHERE IsActive = 1 AND GroupName = ? AND Frequency = ?

	SELECT * FROM [DWHPatientAscendisPreScriptStatus] --WHERE RUNID = @RunId 
	SELECT COUNT(1) FROM [dbo].[DWHPatientAscendisPostScriptStatus] (NOLOCK)

	--UPDATE dbo.DwhDataFeedFileGenerationList 
	--   SET LastFeedRunDate=NULL 
	-- WHERE IsActive = 1 

	UPDATE dbo.DwhDataFeedFileGenerationList 
	   SET LastFeedRunDate=GETDATE() 
	 WHERE IsActive = 1 
	   AND GroupName = ? 
	   AND Frequency = ?
	   --AND DataFileName = ? 

	--UPDATE [dbo].[DwhDataFeedFileGenerationList]
	--   SET IsActive = 0
	-- WHERE ID <> 1
	UPDATE [dbo].[DwhDataFeedFileGenerationList]
	   SET IsActive = 1
	 WHERE ID = 2

	DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50);  
	SET @FeedCurrentRundate = GETDATE();SET @GroupName = 'AscendisPharmaEndocrinology';SET @DataFileName ='CNP_PRE_SCRIPT_STATUS_DAILY_ANOVO';SET @Frequency = 'DAILY';   EXEC dbo.usp_prcDWHGetPreScriptStatus @FeedCurrentRundate,@DataFileName,@GroupName,@Frequency
--SELECT * FROM [dbo].[DwhDataFeedFileGenerationList]

	--DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''CNP_DISPENSE_DAILY_ANOVO'';SET @DataFileName =''CNP_INVENTORY_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetDispense @FeedCurrentRundate,@DataFileName,@GroupName,@Frequency

	--TRUNCATE TABLE [dbo].[DwhDataFeedFileGenerationList]

	INSERT INTO [dbo].[DwhDataFeedFileGenerationList] (DataFileName,SQLStatement,Delimiter,CreatedDate,CreatedBy,ModifiedDate,ModifiedBy,GroupName,Frequency,IsActive)
	SELECT T.DataFileName,T.SQLStatement,T.Delimiter,T.CreatedDate,T.CreatedBy,T.ModifiedDate,T.ModifiedBy,T.GroupName,T.Frequency,T.IsActive
	  FROM
		(		
		SELECT 1 AS SNo,'CNP_PRE_SCRIPT_STATUS_DAILY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_PRE_SCRIPT_STATUS_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetPreScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName, 'DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 2 AS SNo,'CNP_POST_SCRIPT_STATUS_DAILY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_POST_SCRIPT_STATUS_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetPostScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 3 AS SNo,'CNP_INVENTORY_DAILY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_INVENTORY_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetInventory @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 4 AS SNo,'CNP_DISPENSE_DAILY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_DISPENSE_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetDispense @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'DAILY' AS Frequency, 1 AS IsActive
		
		UNION
		SELECT 5 AS SNo,'CNP_OPT_OUT_DAILY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_OPT_OUT_DAILY_ANOVO'';SET @Frequency = ''DAILY'';   EXEC dbo.usp_prcDWHGetOPTOUT @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 6 AS SNo,'CNP_INVENTORY_MONTHLY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_INVENTORY_MONTHLY_ANOVO'';SET @Frequency = ''MONTHLY'';   EXEC dbo.usp_prcDWHGetInventory @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'MONTHLY' AS Frequency, 1 AS IsActive
		
		UNION
		SELECT 7 AS SNo,'CNP_DISPENSE_MONTHLY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_DISPENSE_DAILY_ANOVO'';SET @Frequency = ''MONTHLY'';   EXEC dbo.usp_prcDWHGetDispense @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'MONTHLY' AS Frequency, 1 AS IsActive		
		UNION
		SELECT 8 AS SNo,'CNP_COPAY_WEEKLY_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''AscendisPharmaEndocrinology'';SET @DataFileName =''CNP_COPAY_WEEKLY_ANOVO'';SET @Frequency = ''WEEKLY'';   EXEC dbo.usp_prcDWHGetCopayAdjWeekly @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'AscendisPharmaEndocrinology' AS GroupName,'WEEKLY' AS Frequency, 1 AS IsActive		
		
		----------------CourierHealth----------------
		UNION
		SELECT 1 AS SNo,'CNP_PRE_SCRIPT_STATUS_DAILY_CH' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''CourierHealth'';SET @DataFileName =''CNP_PRE_SCRIPT_STATUS_DAILY_CH'';SET @Frequency = ''TWICE DAILY'';   EXEC dbo.usp_prcDWHGetPreScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'CourierHealth' AS GroupName, 'TWICE DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 2 AS SNo,'CNP_STATUS_DAILY_CH' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''CourierHealth'';SET @DataFileName =''CNP_POST_SCRIPT_STATUS_DAILY_CH'';SET @Frequency = ''TWICE DAILY'';   EXEC dbo.usp_prcDWHGetPostScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'CourierHealth' AS GroupName,'TWICE DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 3 AS SNo,'CNP_DISPENSE_DAILY_CH' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''CourierHealth'';SET @DataFileName =''CNP_DISPENSE_DAILY_CH'';SET @Frequency = ''TWICE DAILY'';   EXEC dbo.usp_prcDWHGetDispense @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'CourierHealth' AS GroupName,'TWICE DAILY' AS Frequency, 1 AS IsActive
		UNION
		SELECT 4 AS SNo,'CNP_OPT_OUT_DAILY_CH' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''CourierHealth'';SET @DataFileName =''CNP_OPT_OUT_DAILY_CH'';SET @Frequency = ''TWICE DAILY'';   EXEC dbo.usp_prcDWHGetOPTOUT @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'CourierHealth' AS GroupName,'TWICE DAILY' AS Frequency, 1 AS IsActive
		--------------SFMC----------------
		UNION
		SELECT 1 AS SNo,'CNP_PRE_SCRIPT_STATUS_SFMC_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''SFMC'';SET @DataFileName =''CNP_PRE_SCRIPT_STATUS_SFMC_ANOVO'';SET @Frequency = ''Daily'';   EXEC dbo.usp_prcDWHGetPreScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'SFMC' AS GroupName, 'Daily' AS Frequency, 1 AS IsActive
		UNION
		SELECT 2 AS SNo,'CNP_POST_SCRIPT_STATUS_SFMC_ANOVO' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''SFMC'';SET @DataFileName =''CNP_POST_SCRIPT_STATUS_SFMC_ANOVO'';SET @Frequency = ''Daily'';   EXEC dbo.usp_prcDWHGetPostScriptStatus @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'SFMC' AS GroupName,'Daily' AS Frequency, 1 AS IsActive
		--UNION
		--SELECT 3 AS SNo,'CNP_DISPENSE_DAILY_SFMC' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''SFMC'';SET @DataFileName =''CNP_DISPENSE_DAILY_SFMC'';SET @Frequency = ''Daily'';   EXEC dbo.usp_prcDWHGetDispense @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
		--			, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'SFMC' AS GroupName,'Daily' AS Frequency, 1 AS IsActive
		UNION
		SELECT 4 AS SNo,'CNP_OPT_OUT_DAILY_SFMC' AS DataFileName,'DECLARE @FeedCurrentRundate DATETIME,@GroupName VARCHAR(255),@DataFileName VARCHAR(255),@Frequency VARCHAR(50); SET @FeedCurrentRundate = GETDATE();SET @GroupName = ''SFMC'';SET @DataFileName =''CNP_OPT_OUT_DAILY_SFMC'';SET @Frequency = ''Daily'';   EXEC dbo.usp_prcDWHGetOPTOUT @FeedCurrentRundate,@GroupName,@DataFileName,@Frequency' AS SQLStatement
					, '|' AS Delimiter, GETDATE() AS CreatedDate, 1 AS CreatedBy, GETDATE() AS ModifiedDate, 1 AS ModifiedBy,'SFMC' AS GroupName,'Daily' AS Frequency, 1 AS IsActive
		) AS T
	 LEFT JOIN dbo.[DwhDataFeedFileGenerationList] L
	   ON T.DataFileName = L.DataFileName
	  AND T.GroupName = L.GroupName  	   
	 WHERE L.DataFileName IS NULL
	 ORDER BY GroupName,T.SNo 

	 
