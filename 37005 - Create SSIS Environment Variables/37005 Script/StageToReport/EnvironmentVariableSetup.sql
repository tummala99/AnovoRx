USE SSISDB
DECLARE @var_environment_name NVARCHAR(255) = N'Test'
DECLARE @var_folderName NVARCHAR(255) = N'AnovoDWH'

DECLARE @var_Anovo_ReportDBConn NVARCHAR(500) = N'Data Source=10.0.200.5;User ID=Anovo_Portal;Password=AnovoPortal2024;Initial Catalog=Anovo_Reports_Test;Provider=MSOLEDBSQL.1;Auto Translate=False;'


/********************Creates folder************************************/
Declare @folder_id BIGINT
IF NOT EXISTS (SELECT folder_id FROM SSISDB.catalog.folders WHERE name = @var_folderName)
BEGIN
	EXEC [SSISDB].[catalog].[create_folder] @folder_name=@var_folderName, @folder_id=@folder_id OUTPUT
	--Select @folder_id
	EXEC [SSISDB].[catalog].[set_folder_description] @folder_name=@var_folderName, @folder_description=N'Recordati_Feed project folder'
END
/********************Creates Environment************************************/
IF NOT EXISTS
	(
	SELECT name
	  FROM SSISDB.catalog.environments
	 WHERE folder_id = (SELECT folder_id FROM SSISDB.catalog.folders WHERE name = @var_folderName)
	   AND [name] = @var_environment_name
	)
BEGIN
	EXEC [SSISDB].[catalog].create_environment @folder_name = @var_folderName
		, @environment_name = @var_environment_name  
		, @environment_description = 'Stage to Report project environment'	
END

--SELECT * FROM SSISDB.catalog.environments

IF NOT EXISTS
(
SELECT * FROM SSISDB.[catalog].environment_variables EV
 INNER JOIN SSISDB.catalog.environments E
    ON EV.environment_id = E.environment_id
 WHERE E.folder_id = (SELECT folder_id FROM SSISDB.catalog.folders WHERE name = @var_folderName)
   AND E.[name] = @var_environment_name
   AND EV.[name] = N'Anovo_ReportDBConn'
   )
	EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Anovo_ReportDBConn', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_Anovo_ReportDBConn, @data_type=N'String'
ELSE
	EXEC [SSISDB].[catalog].set_environment_variable_value @folder_name = @var_folderName
    , @environment_name= @var_environment_name  
    , @variable_name = N'Anovo_ReportDBConn'  
    , @value = @var_Anovo_ReportDBConn

	