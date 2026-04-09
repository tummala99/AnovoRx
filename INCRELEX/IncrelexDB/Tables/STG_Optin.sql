CREATE TABLE dbo.[STG_Optin] (
    [Sitename] nvarchar(255),
    [Pat_type] nvarchar(255),
    [Mrn] float,
    [Last_name] nvarchar(255),
    [First_name] nvarchar(255),
    [Cpk_dyn_links] float,
    [Dateentered] datetime,
    [Status] nvarchar(255),
    [Clinician] nvarchar(255),
    [Visitdate] datetime,
    [Visitloc] nvarchar(255),
    [Visittype2] nvarchar(255),
    [_1_comments] nvarchar(255),
    [_2_did_anovo_receive_a_completed_copy_of_the_opt_in_letter_] nvarchar(255),
    [_3_if_yes__date_received] nvarchar(255),
    [_4_date_opt_in_letter_was_sent_to_patient__date_of_initial_medic] nvarchar(255),
	Import_Date DATETIME DEFAULT GETDATE()
)