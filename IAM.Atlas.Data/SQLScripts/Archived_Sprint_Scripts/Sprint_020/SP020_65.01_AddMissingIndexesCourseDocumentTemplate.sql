
/*
 * SCRIPT: Add Missing Indexes to table CourseDocumentTemplate.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_65.01_AddMissingIndexesCourseDocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseDocumentTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDocumentTemplateCourseId' 
				AND object_id = OBJECT_ID('CourseDocumentTemplate'))
		BEGIN
		   DROP INDEX [IX_CourseDocumentTemplateCourseId] ON [dbo].[CourseDocumentTemplate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDocumentTemplateCourseId] ON [dbo].[CourseDocumentTemplate]
		(
			[CourseId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDocumentTemplateDocumentTemplateId' 
				AND object_id = OBJECT_ID('CourseDocumentTemplate'))
		BEGIN
		   DROP INDEX [IX_CourseDocumentTemplateDocumentTemplateId] ON [dbo].[CourseDocumentTemplate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDocumentTemplateDocumentTemplateId] ON [dbo].[CourseDocumentTemplate]
		(
			[DocumentTemplateId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

