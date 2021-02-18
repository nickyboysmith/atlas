
/*
 * SCRIPT: Add Missing Indexes to table CourseDateTrainerAttendance.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_63.01_AddMissingIndexesCourseDateTrainerAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseDateTrainerAttendance';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateTrainerAttendanceCourseDateId' 
				AND object_id = OBJECT_ID('CourseDateTrainerAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateTrainerAttendanceCourseDateId] ON [dbo].[CourseDateTrainerAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateTrainerAttendanceCourseDateId] ON [dbo].[CourseDateTrainerAttendance]
		(
			[CourseDateId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateTrainerAttendanceCourseId' 
				AND object_id = OBJECT_ID('CourseDateTrainerAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateTrainerAttendanceCourseId] ON [dbo].[CourseDateTrainerAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateTrainerAttendanceCourseId] ON [dbo].[CourseDateTrainerAttendance]
		(
			[CourseId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateTrainerAttendanceTrainerId' 
				AND object_id = OBJECT_ID('CourseDateTrainerAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateTrainerAttendanceTrainerId] ON [dbo].[CourseDateTrainerAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateTrainerAttendanceTrainerId] ON [dbo].[CourseDateTrainerAttendance]
		(
			[TrainerId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

