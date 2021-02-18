
/*
 * SCRIPT: Amend index on CourseDocumentRequestType
 * Author: Daniel Hough
 * Created: 17/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP032_11.01_AmendIndexOnCourseDocumentRequestType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend index on CourseDocumentRequestType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_CourseDocumentRequestType' 
			AND object_id = OBJECT_ID('dbo.CourseDocumentRequestType'))
		BEGIN
			DROP INDEX IX_CourseDocumentRequestType ON dbo.CourseDocumentRequestType;
		END
		
		--Drop Index if Exists
		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='UX_CourseDocumentRequestTypeName' 
			AND object_id = OBJECT_ID('dbo.CourseDocumentRequestType'))
		BEGIN
			DROP INDEX UX_CourseDocumentRequestTypeName ON dbo.CourseDocumentRequestType;
		END
		
		CREATE UNIQUE INDEX UX_CourseDocumentRequestTypeName ON dbo.CourseDocumentRequestType
		(
			[Name] ASC
		);

		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

