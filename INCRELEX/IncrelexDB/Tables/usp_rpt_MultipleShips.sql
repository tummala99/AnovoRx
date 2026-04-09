USE IncrelexDev
GO

IF (OBJECT_ID('dbo.usp_rpt_MultipleShips') IS NOT NULL)
	DROP PROCEDURE dbo.usp_rpt_MultipleShips
GO

CREATE PROCEDURE dbo.usp_rpt_MultipleShips
AS
/*
	Purpose: Consolidate and generate Patient multiple Shipments Report data
	
	EXEC dbo.usp_rpt_MultipleShips

*/
BEGIN

	/****************0044 RESTART Date*************************/
	IF(OBJECT_ID('dbo.STG_0046MultipleShips_Output') IS NOT NULL)
			TRUNCATE TABLE dbo.STG_0046MultipleShips_Output
	ELSE
	BEGIN
		CREATE TABLE dbo.STG_0046MultipleShips_Output (mrn INT,CountOfdispense_date INT,[Multiple Ships] INT)
	END
	
	DECLARE @MonthStartDate DATE
	SET @MonthStartDate = DATEADD(DAY,1,EOMONTH(GETDATE()-100,-1))
	--SELECT @MonthStartDate

	;WITH [0009MonthlyShipDetail]
	  AS
		(
		SELECT MRN, dispense_date
		  FROM dbo.STG_Dispense
		 WHERE (dispense_date >= @MonthStartDate)
		 --WHERE (dispense_date>='4/1/2025')		-- Clarification required from Krushna.
		)
	
	INSERT INTO dbo.STG_0046MultipleShips_Output (mrn,CountOfdispense_date,[Multiple Ships]				
				)
	SELECT [MRN]
	     , Count([dispense_date]) AS CountOfdispense_date
		 , Count([dispense_date]) - 1 AS [Multiple Ships]		 
	  FROM [0009MonthlyShipDetail]
	 GROUP BY [MRN]
	HAVING (Count([dispense_date])>1)

	--SELECT * FROM dbo.STG_0046MultipleShips_Output
END
	