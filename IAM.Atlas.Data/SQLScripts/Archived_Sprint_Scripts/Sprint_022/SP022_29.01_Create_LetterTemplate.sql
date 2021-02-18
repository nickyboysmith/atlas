/*
	SCRIPT: Create LetterTemplate Table
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_29.01_Create_LetterTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create LetterTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplate'
		
		/*
		 *	Create LetterTemplate Table
		 */
		IF OBJECT_ID('dbo.LetterTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterTemplate;
		END

		CREATE TABLE LetterTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT
			, LetterActionId INT
			, Title VARCHAR(100)
			, Notes VARCHAR(400)
			, DocumentTemplateId INT
			, DateLastUpdated DATETIME
			, UpdatedByUserId INT
			, CONSTRAINT FK_LetterTemplate_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_LetterTemplate_LetterAction FOREIGN KEY (LetterActionId) REFERENCES LetterAction(Id)
			, CONSTRAINT FK_LetterTemplate_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
			, CONSTRAINT FK_LetterTemplate_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;