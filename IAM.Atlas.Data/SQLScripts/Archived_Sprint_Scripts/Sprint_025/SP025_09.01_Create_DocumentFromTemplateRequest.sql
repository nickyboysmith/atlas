/*
	SCRIPT: Create DocumentFromTemplateRequest Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_09.01_Create_DocumentFromTemplateRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentFromTemplateRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentFromTemplateRequest'
		
		/*
		 *	Create DocumentFromTemplateRequest Table
		 */
		IF OBJECT_ID('dbo.DocumentFromTemplateRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentFromTemplateRequest;
		END

		CREATE TABLE DocumentFromTemplateRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentTemplateId INT
			, NewDocumentName VARCHAR(100)
			, NewDocumentPath VARCHAR(800)
			, RequestByUserId INT
			, DateRequested DATETIME
			, RequestCompleted BIT DEFAULT 0
			, Comments VARCHAR(400)
			, CONSTRAINT FK_DocumentFromTemplateRequest_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
			, CONSTRAINT FK_DocumentFromTemplateRequest_User FOREIGN KEY (RequestByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;