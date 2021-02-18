
/*
 * SCRIPT: Add Missing Indexes to table CourseDateClientAttendance.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_62.01_AddMissingIndexesCourseDateClientAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseDateClientAttendance';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateClientAttendanceCourseDateId' 
				AND object_id = OBJECT_ID('CourseDateClientAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateClientAttendanceCourseDateId] ON [dbo].[CourseDateClientAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateClientAttendanceCourseDateId] ON [dbo].[CourseDateClientAttendance]
		(
			[CourseDateId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateClientAttendanceCourseId' 
				AND object_id = OBJECT_ID('CourseDateClientAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateClientAttendanceCourseId] ON [dbo].[CourseDateClientAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateClientAttendanceCourseId] ON [dbo].[CourseDateClientAttendance]
		(
			[CourseId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateClientAttendanceClientId' 
				AND object_id = OBJECT_ID('CourseDateClientAttendance'))
		BEGIN
		   DROP INDEX [IX_CourseDateClientAttendanceClientId] ON [dbo].[CourseDateClientAttendance];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateClientAttendanceClientId] ON [dbo].[CourseDateClientAttendance]
		(
			[ClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

