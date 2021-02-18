
/*
 * SCRIPT: Add Missing Indexes to table CoursePreviousId.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_22.01_AddMissingIndexesCoursePreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CoursePreviousId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CoursePreviousIdCourseIdPreviousCourseId' 
				AND object_id = OBJECT_ID('CoursePreviousId'))
		BEGIN
		   DROP INDEX [IX_CoursePreviousIdCourseIdPreviousCourseId] ON [dbo].[CoursePreviousId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CoursePreviousIdCourseIdPreviousCourseId] ON [dbo].[CoursePreviousId]
		(
			[CourseId], [PreviousCourseId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

