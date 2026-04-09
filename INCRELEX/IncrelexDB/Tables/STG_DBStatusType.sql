CREATE TABLE dbo.[STG_DBStatusType] (
    [Order Last Event Status] nvarchar(255),
    [Dashboard Status ] nvarchar(255),
	Import_Date	DATETIME DEFAULT GETDATE()
)