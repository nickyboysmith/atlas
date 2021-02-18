
/*
 * SCRIPT: Add Missing Indexes to table CourseTrainer.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_25.01_AddMissingIndexesCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseTrainer';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTrainerCourseIdTrainerId' 
				AND object_id = OBJECT_ID('CourseTrainer'))
		BEGIN
		   DROP INDEX [IX_CourseTrainerCourseIdTrainerId] ON [dbo].[CourseTrainer];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTrainerCourseIdTrainerId] ON [dbo].[CourseTrainer]
		(
			[CourseId], [TrainerId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

