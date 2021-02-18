/*
 * SCRIPT: Alter Table CourseTrainer Recreate Indexes
 * Author: Nick Smith
 * Created: 29/11/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP045_20.02_AmendCourseTrainerRecreateIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop Existing Constraints and Recreate New Index';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UC_CourseTrainer' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [UC_CourseTrainer] ON [dbo].[CourseTrainer];
		END

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_CourseTrainer_BookedForSessionNumber' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [UX_CourseTrainer_BookedForSessionNumber] ON [dbo].[CourseTrainer];
		END

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_CourseTrainer_CourseTrainerCourseDateBookedForSessionNumber' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [UX_CourseTrainer_CourseTrainerCourseDateBookedForSessionNumber] ON [dbo].[CourseTrainer];
		END

		CREATE UNIQUE NONCLUSTERED INDEX UX_CourseTrainer_CourseTrainerCourseDateBookedForSessionNumber ON dbo.CourseTrainer
		(
			TrainerId,
			CourseId,
			CourseDateId,
			BookedForSessionNumber
		);
					

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
