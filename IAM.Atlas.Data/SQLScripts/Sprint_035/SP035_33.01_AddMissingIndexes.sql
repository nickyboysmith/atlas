
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 02/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_33.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseLockedCourseId' 
				AND object_id = OBJECT_ID('CourseLocked'))
		BEGIN
		   DROP INDEX [IX_CourseLockedCourseId] ON [dbo].[CourseLocked];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseLockedCourseId] ON [dbo].[CourseLocked]
		(
			[CourseId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseProfileUneditableCourseId' 
				AND object_id = OBJECT_ID('CourseProfileUneditable'))
		BEGIN
		   DROP INDEX [IX_CourseProfileUneditableCourseId] ON [dbo].[CourseProfileUneditable];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseProfileUneditableCourseId] ON [dbo].[CourseProfileUneditable]
		(
			[CourseId] ASC
		) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

