
/*
 * SCRIPT: Alter Indexes to table CourseSchedule.
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_43.01_AlterIndexesCourseScheduleAddCourseIdAndDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseSchedule add CourseId and Date';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseScheduleCourseIdDate' 
				AND object_id = OBJECT_ID('CourseSchedule'))
		BEGIN
		   DROP INDEX [IX_CourseScheduleCourseIdDate] ON [dbo].[CourseSchedule];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseScheduleCourseId' 
				AND object_id = OBJECT_ID('CourseSchedule'))
		BEGIN
		   DROP INDEX [IX_CourseScheduleCourseId] ON [dbo].[CourseSchedule];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseScheduleCourseId] ON [dbo].[CourseSchedule]
		(
			[CourseId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseScheduleDate' 
				AND object_id = OBJECT_ID('CourseSchedule'))
		BEGIN
		   DROP INDEX [IX_CourseScheduleDate] ON [dbo].[CourseSchedule];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseScheduleDate] ON [dbo].[CourseSchedule]
		(
			[Date]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

