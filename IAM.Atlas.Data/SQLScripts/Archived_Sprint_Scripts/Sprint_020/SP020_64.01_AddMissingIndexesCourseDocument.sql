
/*
 * SCRIPT: Add Missing Indexes to table CourseDocument.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_64.01_AddMissingIndexesCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseDocument';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDocumentCourseId' 
				AND object_id = OBJECT_ID('CourseDocument'))
		BEGIN
		   DROP INDEX [IX_CourseDocumentCourseId] ON [dbo].[CourseDocument];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDocumentCourseId] ON [dbo].[CourseDocument]
		(
			[CourseId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDocumentDocumentId' 
				AND object_id = OBJECT_ID('CourseDocument'))
		BEGIN
		   DROP INDEX [IX_CourseDocumentDocumentId] ON [dbo].[CourseDocument];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDocumentDocumentId] ON [dbo].[CourseDocument]
		(
			[DocumentId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

