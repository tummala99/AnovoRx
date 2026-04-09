CREATE TABLE dbo.[STG_Queue] (
    [mrn] VARCHAR(50),
    [patient_team] VARCHAR(50),
    [move_date] VARCHAR(50),
    [new_list] VARCHAR(1000),
	Import_Date	DATETIME DEFAULT GETDATE()
)

