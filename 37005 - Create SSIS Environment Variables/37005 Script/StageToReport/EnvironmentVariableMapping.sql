USE SSISDB
Declare @reference_id bigint
DECLARE @var_environment_name NVARCHAR(255) = N'Test'
DECLARE @var_folderName NVARCHAR(255) = N'AnovoDWH'
DECLARE @var_projectName NVARCHAR(255) = N'AnovoDWH'
DECLARE @var_objectName NVARCHAR(255) = N'AnovoDWH'

--SELECT * FROM SSISDB.catalog.environment_references
--SELECT * FROM SSISDB.[internal].[projects]

IF NOT EXISTS
	(
	SELECT * 
	  FROM SSISDB.catalog.environment_references ER
	 INNER JOIN SSISDB.[internal].[projects] P
		ON ER.project_id = P.project_id
	 WHERE P.folder_id = (SELECT folder_id FROM SSISDB.catalog.folders WHERE name = @var_folderName)
	   AND ER.environment_name = @var_environment_name
	)
BEGIN
	EXEC [SSISDB].[catalog].[create_environment_reference] @environment_name=@var_environment_name, @reference_id=@reference_id OUTPUT, @project_name=@var_projectName, @folder_name=@var_folderName, @reference_type=R
END
--Select @reference_id

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'Anovo_ReportDBConn', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'Anovo_ReportDBConn'

