USE SSISDB
Declare @reference_id bigint
DECLARE @var_environment_name NVARCHAR(255) = N'UAT'--'QA'
DECLARE @var_folderName NVARCHAR(255) = N'Increlex'
DECLARE @var_projectName NVARCHAR(255) = N'INCRELEX_SSIS'
DECLARE @var_objectName NVARCHAR(255) = N'INCRELEX_SSIS'

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

--
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'ActiveSpecialtyPrescribers', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'ActiveSpecialtyPrescribers'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'Archivepath', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'Archivepath'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'AuthNoteMapping', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'AuthNoteMapping'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DBStatusType', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DBStatusType'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DatabaseName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DatabaseName'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DatabasePassword', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DatabasePassword'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DatabaseUserName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DatabaseUserName'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DBStatusType', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DBStatusType'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'DispenseFileName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'DispenseFileName'

EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'EmailSendCC', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'EmailSendCC'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'EmailSendFrom', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'EmailSendFrom'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'EmailSendFromName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'EmailSendFromName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'EmailSendTo', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'EmailSendTo'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'Environment', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'Environment'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'ImportFileString', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'ImportFileString'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'NCPDPFileName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'NCPDPFileName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'NotesFileName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'NotesFileName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'OrderLastEventMapping', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'OrderLastEventMapping'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'OrdersFileName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'OrdersFileName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'PAAppealNotesFileName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'PAAppealNotesFileName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'Patients', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'Patients'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'Queue', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'Queue'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'ServerName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'ServerName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SMTPPassword', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'SMTPPassword'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SMTPPort', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'SMTPPort'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SMTPServerName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'SMTPServerName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SMTPUserName', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'SMTPUserName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SourceFilesPath', @object_name=@var_objectName, @folder_name=@var_folderName, @project_name=@var_projectName, @value_type=R, @parameter_value=N'SourceFilesPath'



