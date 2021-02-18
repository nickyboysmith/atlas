
/*
 * SCRIPT: Alter Indexes to table CourseTrainer.
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_44.01_AlterMissingIndexesCourseTrainerAddCourseIdAndTrainerId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseTrainer, add CourseId and TrainerId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTrainerCourseIdTrainerId' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [IX_CourseTrainerCourseIdTrainerId] ON [dbo].[CourseTrainer];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTrainerCourseId' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [IX_CourseTrainerCourseId] ON [dbo].[CourseTrainer];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTrainerCourseId] ON [dbo].[CourseTrainer]
		(
			[CourseId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTrainerTrainerId' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [IX_CourseTrainerTrainerId] ON [dbo].[CourseTrainer];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTrainerTrainerId] ON [dbo].[CourseTrainer]
		(
			[TrainerId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

