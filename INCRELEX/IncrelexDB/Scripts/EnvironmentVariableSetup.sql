USE SSISDB
DECLARE @var_environment_name NVARCHAR(255) = N'UAT'--'QA'
DECLARE @var_folderName NVARCHAR(255) = N'Increlex'
DECLARE @var_ActiveSpecialtyPrescribers NVARCHAR(500) = N'Active Specialty Prescribers.csv'
DECLARE @var_Archivepath NVARCHAR(500) = N'C:\\SSISPackages\\Increlex\\ArchivePath'
DECLARE @var_AuthNoteMapping NVARCHAR(500) = N'PA and Appeal Mapping2.xlsx'
DECLARE @var_DatabaseName NVARCHAR(500) = N'IncrelexUAT'--'IncrelexQA'--'IncrelexDev'
DECLARE @var_DatabasePassword NVARCHAR(500) = N'Hub123!@#'
DECLARE @var_DatabaseUserName NVARCHAR(500) = N'HubengQa'
--DECLARE @var_DatabasePassword NVARCHAR(500) = N'Nexu$123!@#'
--DECLARE @var_DatabaseUserName NVARCHAR(500) = N'India'
DECLARE @var_DBStatusType NVARCHAR(500) = N'DashboardStatusMapping1.xlsx'
DECLARE @var_DispenseFileName NVARCHAR(500) = N'Active Specialty Prescribers.csv'
DECLARE @var_EmailSendCC NVARCHAR(500) = N'Active Specialty Prescribers.csv'
DECLARE @var_EmailSendFrom NVARCHAR(500) = N'QASupport@anovorx.com'
DECLARE @var_EmailSendFromName NVARCHAR(500) = N'AnovoRX Support'
DECLARE @var_EmailSendTo NVARCHAR(500) = N'India'
DECLARE @var_Environment NVARCHAR(500) = N'UAT'--'QA'--'DEV'
DECLARE @var_ImportFileString NVARCHAR(500) = N'Increlex'
DECLARE @var_NCPDPFileName NVARCHAR(500) = N'Increlex_NCPDP.csv'
DECLARE @var_NotesFileName NVARCHAR(500) = N'Increlex_Notes.csv'
DECLARE @var_OrderLastEventMapping NVARCHAR(500) = N'OrderLastEventMapNew4.xlsx'
DECLARE @var_OrdersFileName NVARCHAR(500) = N'Increlex_Orders.csv'
DECLARE @var_PAAppealNotesFileName NVARCHAR(500) = N'PA and Appeal Notes Increlex.csv'
DECLARE @var_Patients NVARCHAR(500) = N'Increlex_Patients.csv'
DECLARE @var_Queue NVARCHAR(500) = N'Increlex_Queue.csv'
DECLARE @var_ServerName NVARCHAR(500) = N'hubtestdb1.cyvjdz9ti1rg.us-east-1.rds.amazonaws.com' -- QA
--DECLARE @var_ServerName NVARCHAR(500) = N'50.17.232.197' -- QA
--DECLARE @var_ServerName NVARCHAR(500) = N'anovodev1.c2xt29qw5zzh.ap-south-1.rds.amazonaws.com' -- DEV
DECLARE @var_SMTPPassword NVARCHAR(500) = N'whyISthis501notworking'

DECLARE @var_SMTPPort NVARCHAR(255) = N'587'
DECLARE @var_SMTPServerName NVARCHAR(255) = N'smtp.office365.com'
DECLARE @var_SMTPUserName NVARCHAR(255) = N'QASupport@anovorx.com'
DECLARE @var_SourceFilesPath NVARCHAR(255) = N'C:\\SSISPackages\\Increlex\\SourcePath'

/********************Creates folder************************************/
Declare @folder_id bigint
EXEC [SSISDB].[catalog].[create_folder] @folder_name=@var_folderName, @folder_id=@folder_id OUTPUT
--Select @folder_id
EXEC [SSISDB].[catalog].[set_folder_description] @folder_name=@var_folderName, @folder_description=N'Increlex project folder'
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
		, @environment_description = 'Increlex project environment'	
END

--SELECT * FROM SSISDB.catalog.environments

IF NOT EXISTS
(
SELECT * FROM SSISDB.[catalog].environment_variables EV
 INNER JOIN SSISDB.catalog.environments E
    ON EV.environment_id = E.environment_id
 WHERE E.folder_id = (SELECT folder_id FROM SSISDB.catalog.folders WHERE name = @var_folderName)
   AND E.[name] = @var_environment_name
   AND EV.[name] = N'ActiveSpecialtyPrescribers'
   )
	EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'ActiveSpecialtyPrescribers', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_ActiveSpecialtyPrescribers, @data_type=N'String'
ELSE
	EXEC [SSISDB].[catalog].set_environment_variable_value @folder_name = @var_folderName
    , @environment_name= @var_environment_name  
    , @variable_name = N'ActiveSpecialtyPrescribers'  
    , @value = @var_ActiveSpecialtyPrescribers 

EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Archivepath', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_Archivepath, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'AuthNoteMapping', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_AuthNoteMapping, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'DatabaseName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_DatabaseName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'DatabasePassword', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_DatabasePassword, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'DatabaseUserName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_DatabaseUserName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'DBStatusType', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_DBStatusType, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'DispenseFileName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_DispenseFileName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'EmailSendCC', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_EmailSendCC, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'EmailSendFrom', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_EmailSendFrom, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'EmailSendFromName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_EmailSendFromName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'EmailSendTo', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_EmailSendTo, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Environment', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_Environment, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'ImportFileString', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_ImportFileString, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'NCPDPFileName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_NCPDPFileName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'NotesFileName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_NotesFileName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'OrderLastEventMapping', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_OrderLastEventMapping, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'OrdersFileName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_OrdersFileName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'PAAppealNotesFileName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_PAAppealNotesFileName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Patients', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_Patients, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'Queue', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_Queue, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'ServerName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_ServerName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SMTPPassword', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_SMTPPassword, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SMTPPort', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_SMTPPort, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SMTPServerName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_SMTPServerName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SMTPUserName', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_SMTPUserName, @data_type=N'String'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SourceFilesPath', @sensitive=False, @description=N'', @environment_name=@var_environment_name, @folder_name=@var_folderName, @value=@var_SourceFilesPath, @data_type=N'String'


