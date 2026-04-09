CREATE TABLE dbo.[STG_AuthNoteMapping] (
    [Note Subject] nvarchar(255),
    [Primary] nvarchar(255),
    [Secondary] nvarchar(255),
	Import_Date	DATETIME DEFAULT GETDATE()
)

