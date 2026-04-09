IF (OBJECT_ID('dbo.usp_rpt_RestartDate') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_RestartDate
GO

CREATE PROCEDURE dbo.usp_rpt_RestartDate
AS
/*
	Purpose: Consolidate and generate Patient Dispense Restart ships Report data
	
	EXEC dbo.usp_rpt_RestartDate

*/
BEGIN

	/****************0044 RESTART Date*************************/
	IF(OBJECT_ID('dbo.STG_0044RESTARTDate_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_0044RESTARTDate_Output
	ELSE
	BEGIN
		CREATE TABLE dbo.STG_0044RESTARTDate_Output (mrn INT,[Id] INT,patient_status VARCHAR(255)
				,patient_last_discharge_date DATE
				, MinOfdispense_date DATE
				)
	END	

	
	
	
	;WITH [0042RestartPatients]
	  AS
		(
		SELECT mrn,
			   CAST([mrn] AS BIGINT) - 40119 AS ID,
			   patient_status,
			   CAST(patient_last_discharge_date AS DATE) AS patient_last_discharge_date
		  FROM dbo.STG_Patients
		 WHERE TRIM(patient_status) IN ( 'ACTIVE', 'PENDING' )
		   AND (ISNULL(patient_last_discharge_date,'') != '') --94
		),[0043RestartShips]
	  AS
	    (
		SELECT A.mrn, A.ID, A.patient_status
			 , A.patient_last_discharge_date
			 , CAST(NULLIF(D.dispense_date,'') AS DATE) AS dispense_date
		  FROM [0042RestartPatients] A 
		 INNER JOIN dbo.STG_Dispense D 
		    ON A.mrn = D.mrn
		 WHERE (CAST(NULLIF(D.dispense_date,'') AS DATE)>A.[patient_last_discharge_date])
	    )

		--SELECT * FROM [0043RestartShips] -- 310
	INSERT INTO dbo.STG_0044RESTARTDate_Output (mrn,[Id],patient_status,patient_last_discharge_date
				, MinOfdispense_date			
				)
	SELECT mrn, ID, patient_status
		 , NULLIF(patient_last_discharge_date,'') AS patient_last_discharge_date
		 , Min(NULLIF(dispense_date,'')) AS MinOfdispense_date
	  FROM [0043RestartShips]
	 GROUP BY mrn, ID, patient_status, patient_last_discharge_date;

	--SELECT * FROM dbo.STG_0044RESTARTDate_Output
END		   
