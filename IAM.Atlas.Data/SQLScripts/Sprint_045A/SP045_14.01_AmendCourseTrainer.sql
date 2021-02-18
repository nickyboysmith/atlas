/*
 * SCRIPT: Alter Table CourseTrainer 
 * Author: Nick Smith
 * Created: 08/11/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP045_14.01_AmendCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Constraint and Index';
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

		/*
		 *	Drop Constraints if they Exist
		 */		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseTrainer_TrainingSession')
				   AND parent_object_id = OBJECT_ID(N'dbo.CourseTrainer')
		)
		BEGIN
			ALTER TABLE CourseTrainer DROP CONSTRAINT FK_CourseTrainer_TrainingSession;
		END

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_CourseTrainer_BookedForSessionNumber' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [UX_CourseTrainer_BookedForSessionNumber] ON [dbo].[CourseTrainer];
		END

		CREATE UNIQUE NONCLUSTERED INDEX UX_CourseTrainer_BookedForSessionNumber ON dbo.CourseTrainer
		(
			TrainerId,
			CourseId,
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
