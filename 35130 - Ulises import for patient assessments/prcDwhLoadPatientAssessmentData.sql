USE Anovo_Reports;

IF (OBJECT_ID('dbo.prcDwhLoadPatientAssessmentData') IS NOT NULL)
	DROP PROCEDURE dbo.prcDwhLoadPatientAssessmentData
GO

CREATE PROCEDURE dbo.prcDwhLoadPatientAssessmentData (@ProcessId INT
													 ,@user VARCHAR(100))
AS
/*	      
	Purpose: Procedure to get and load the modified and new Patient Assessment data from Stage to the Report database	
	
	test:
		DECLARE @ProcessId VARCHAR(10), @user VARCHAR(255)
		EXEC dbo.prcDwhLoadPatientAssessmentData @ProcessId, @user

*/
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
		/******************************************************************************************************
		* Create Patient Assessment table in Dataware house database from existing 
			table schema in Stage if its not yet created.
		*******************************************************************************************************/
		IF(OBJECT_ID('[dbo].DwhPatientAssessments') IS NULL)
			SELECT *,CAST('' AS VARCHAR(255)) AS QuestionOrder 
			  INTO [dbo].[DwhPatientAssessments] 
			  FROM [dbo].[PatientAssessmentsProd] WHERE 1 = 2
		
		/******************************************************************************************************
		* Get max Modification date from datawarehouse table to get the new tranasctions loaded into stage.
		*******************************************************************************************************/
		DECLARE @ErrorMessage VARCHAR(2000);
		DECLARE @ProcessName varchar(50) = 'prcDwhLoadPatientAssessmentData';

		IF (@ProcessId is null OR @ProcessId = 0)
		BEGIN
			--EXEC dbo.prcDwhLogging @ProcessId,'INFO',@ProcessName,'INSIDE THE IF',@User;
			SELECT @ProcessId = next value for dbo.SeqDwhProcessId
			,@User = SUSER_NAME()                   
		END             
		
		EXEC dbo.prcDwhLogging @ProcessId,'INFO',@ProcessName,'Process started',@User;

		DECLARE @MaxModifiedDate DATETIME
		SELECT @MaxModifiedDate = MAX(ModifiedOn) FROM [dbo].[DwhPatientAssessments] --2025-05-27 17:26:08.243
		
		BEGIN TRAN

		/******************************************************************************************************
		* If max modification date is null, then load the entire assessment data into warehouse.
		*******************************************************************************************************/
		IF(@MaxModifiedDate IS NULL)
		BEGIN

			/******************************************************************************************************
			* Get and loads the Patient recent assessment data into warehouse.
			*******************************************************************************************************/
			INSERT INTO [dbo].[DwhPatientAssessments] (PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
							,Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn,QuestionOrder)
			SELECT PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
				 , Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn 
				 --, ROW_NUMBER() OVER(PARTITION BY AssessmentId ORDER BY QuestionNumber) AS QuestionOrder
				 , (CAST(FORMAT(QuestionNumber,'00') AS VARCHAR(100)) +'.'+ CAST(ROW_NUMBER() OVER(PARTITION BY AssessmentId,QuestionNumber ORDER BY QuestionNumber,AnswerId) AS VARCHAR(100))) AS QuestionOrder
			  FROM
				 (	
					SELECT * 
					  FROM
						(
						SELECT *, ROW_NUMBER() OVER (PARTITION BY PatientId,AssessmentId,QuestionId,AnswerId ORDER BY ModifiedOn DESC) AS RowId 
						  FROM [dbo].[PatientAssessmentsProd] --2025-05-27 17:26:08.243
						 --WHERE ModifiedOn <= '2025-05-22 22:38:10.153'
						) AS T
					 WHERE T.RowId = 1
				) AS T
			 ORDER BY ModifiedOn

			 Print 'Initial Version of Patient Assessment data has been loaded'
		END
		ELSE
		BEGIN
			/******************************************************************************************************
			* Get latest assessment data into temp resultset from Stage.
			*******************************************************************************************************/
			--DECLARE @MaxModifiedDate DATETIME = '2025-05-22 22:38:10.153'
			--SELECT @MaxModifiedDate = MAX(ModifiedOn) FROM Anovo_Reports.[dbo].[DwhPatientAssessments] --2025-05-27 17:26:08.243
			
			IF(OBJECT_ID('tempdb..#LatestPatientAssessments') IS NOT NULL)
				DROP TABLE #LatestPatientAssessments

			SELECT PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
							,Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn
			  INTO #LatestPatientAssessments						
			  FROM
				(
				SELECT *, ROW_NUMBER() OVER (PARTITION BY PatientId,AssessmentId,QuestionId,AnswerId ORDER BY ModifiedOn DESC,PatientAssessmentId DESC) AS RowId 
				  FROM [dbo].[PatientAssessmentsProd] --2025-05-27 17:26:08.243
				 WHERE ModifiedOn > @MaxModifiedDate
				) AS T
			 WHERE T.RowId = 1
			 ORDER BY ModifiedOn

			 --SELECT DISTINCT patientId,AssessmentId FROM #LatestPatientAssessments -- 246

			/******************************************************************************************************
			* Delete the modified assessments from warehouse.
			*******************************************************************************************************/
			 --SELECT DISTINCT A.patientId,A.AssessmentId 
			 DELETE A
			   FROM [dbo].[DwhPatientAssessments] A
			  INNER JOIN #LatestPatientAssessments B
			     ON A.patientId = B.patientId
				AND A.AssessmentId = B.AssessmentId -- 96

			/******************************************************************************************************
			* Loading modifed/New Patient assessment data into warehouse.
			*******************************************************************************************************/
			INSERT INTO [dbo].[DwhPatientAssessments] (PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
							,Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn,QuestionOrder)
			SELECT PatientAssessmentId,AssessmentId,QuestionId,AnswerId,patientId,EnteredDdate,VisitDate,Clinician,[Status]
							,Title,ActiveYn,Category,AssessmentType,CompleteYn,QuestionNumber,Question,Answer,ModifiedOn
				 , (CAST(FORMAT(QuestionNumber,'00') AS VARCHAR(100)) +'.'+ CAST(ROW_NUMBER() OVER(PARTITION BY AssessmentId,QuestionNumber ORDER BY QuestionNumber,AnswerId) AS VARCHAR(100))) AS QuestionOrder
			  FROM #LatestPatientAssessments
			 ORDER BY ModifiedOn
			
			Print 'Latest Version of Patient Assessment data has been loaded'			
			
		END

		EXEC dbo.prcDwhLogging @ProcessId,'INFO',@ProcessName,'Process finished',@User;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRAN
			
		SELECT @ErrorMessage = ERROR_MESSAGE() 
		EXEC dbo.prcDwhLogging @ProcessId,'ERROR',@ProcessName,@ErrorMessage,@user;
	END CATCH
END