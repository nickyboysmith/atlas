/*
	SCRIPT: Create DocumentFromTemplate Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_04.01_Create_DocumentFromTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentFromTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentFromTemplate'
		
		/*
		 *	Create DocumentFromTemplate Table
		 */
		IF OBJECT_ID('dbo.DocumentFromTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentFromTemplate;
		END

		CREATE TABLE DocumentFromTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId int
			, DocumentTemplateId int
			, DateCreated DateTime
			, CONSTRAINT FK_DocumentFromTemplate_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentFromTemplate_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;