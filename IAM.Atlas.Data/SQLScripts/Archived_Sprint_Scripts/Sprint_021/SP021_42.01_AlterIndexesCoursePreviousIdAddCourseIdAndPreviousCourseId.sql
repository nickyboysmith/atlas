
/*
 * SCRIPT: Alter Indexes Indexes to table CoursePreviousId.
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_42.01_AlterIndexesCoursePreviousIdAddCourseIdAndPreviousCourseId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CoursePreviousId, add CourseId and PreviousCourseId ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CoursePreviousIdCourseIdPreviousCourseId' 
				AND object_id = OBJECT_ID('CoursePreviousId'))
		BEGIN
		   DROP INDEX [IX_CoursePreviousIdCourseIdPreviousCourseId] ON [dbo].[CoursePreviousId];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CoursePreviousIdCourseId' 
				AND object_id = OBJECT_ID('CoursePreviousId'))
		BEGIN
		   DROP INDEX [IX_CoursePreviousIdCourseId] ON [dbo].[CoursePreviousId];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CoursePreviousIdCourseId] ON [dbo].[CoursePreviousId]
		(
			[CourseId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CoursePreviousIdPreviousCourseId' 
				AND object_id = OBJECT_ID('CoursePreviousId'))
		BEGIN
		   DROP INDEX [IX_CoursePreviousIdPreviousCourseId] ON [dbo].[CoursePreviousId];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CoursePreviousIdPreviousCourseId] ON [dbo].[CoursePreviousId]
		(
			[PreviousCourseId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

