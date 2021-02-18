/*
	SCRIPT: Create CourseDocumentTemplate Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_10.01_Create_CourseDocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplateOwner Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDocumentTemplate'
		
		/*
		 *	Create CourseDocumentTemplate Table
		 */
		IF OBJECT_ID('dbo.CourseDocumentTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDocumentTemplate;
		END

		CREATE TABLE CourseDocumentTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int
			, DocumentTemplateId int
			, CONSTRAINT FK_CourseDocumentTemplate_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDocumentTemplate_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;