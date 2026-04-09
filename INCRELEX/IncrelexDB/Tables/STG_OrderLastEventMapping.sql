CREATE TABLE dbo.[STG_OrderLastEventMapping] (
    [Order Last Event] nvarchar(255),
    [Queue] nvarchar(255),
    [Order Last Event Status] nvarchar(255),
    [Anovo DB (Order Last Event Status)] nvarchar(255),
    [Dashboard Status] nvarchar(255),
    [Status Type] nvarchar(255),
    [other] nvarchar(255),
    [SF] nvarchar(255),
    [roll exhaust] nvarchar(255),
	Import_Date	DATETIME DEFAULT GETDATE()
)