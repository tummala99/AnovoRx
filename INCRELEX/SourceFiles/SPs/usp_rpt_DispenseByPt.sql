IF (OBJECT_ID('dbo.usp_rpt_DispenseByPt') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_DispenseByPt
GO

CREATE PROCEDURE dbo.usp_rpt_DispenseByPt
AS
/*
	Purpose: Consolidate and generate Patient Dispense Report data
	
	EXEC dbo.usp_rpt_DispenseByPt

*/
BEGIN
	/************[0040 Dispense Type]***************/
	IF(OBJECT_ID('dbo.STG_DispenseByPt_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_DispenseByPt_Output
	ELSE
	BEGIN
		CREATE TABLE dbo.STG_DispenseByPt_Output ([Month] VARCHAR(10)
						,[Quick Start] INT
						,[Bridge] INT
						,[PAP] INT
				)
	END	

	INSERT INTO dbo.STG_DispenseByPt_Output ([Month],[Quick Start],[Bridge],[PAP])
	SELECT [Month], [Quick Start],[Bridge],[PAP] 
	  FROM
		(
		SELECT DISTINCT --mrn,
						CAST([mrn] AS BIGINT) - 40119 AS [Patient ID],
						--dispense_date,
						FORMAT(CAST(NULLIF(dispense_date,'') AS DATE),'MM-yyyy') AS [Month],
						CASE
							 WHEN TRIM([line9]) LIKE '%Starter%' THEN 'Quick Start'
							 WHEN TRIM([line9]) LIKE '%Bridge%' THEN 'Bridge'
							 WHEN TRIM([line9]) LIKE '%Comp%' THEN 'PAP'
							 ELSE 'Commercial' 
						END AS [Dispense Type]
		  FROM dbo.STG_Dispense
		  )  AS T
		  PIVOT
		  (
		  COUNT([Patient ID]) 
		  FOR [Dispense Type] IN ([Quick Start],[Bridge],[PAP])
		  ) As PT
END