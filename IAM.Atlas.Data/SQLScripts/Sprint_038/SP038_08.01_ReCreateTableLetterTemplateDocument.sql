/*
 * SCRIPT: ReCreate Tables LetterTemplateDocument
 * Author: Robert Newnham
 * Created: 23/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_08.01_ReCreateTableLetterTemplateDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ReCreate Tables LetterTemplateDocument';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplateDocument'
		
		/*
		 *	Create LetterTemplateDocument Table
		 */
		IF OBJECT_ID('dbo.LetterTemplateDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterTemplateDocument;
		END

		CREATE TABLE LetterTemplateDocument(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LetterTemplateId INT NOT NULL INDEX IX_LetterTemplateDocumentLetterTemplateId NONCLUSTERED
			, DateRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestCompleted BIT NOT NULL DEFAULT 'False' INDEX IX_LetterTemplateDocumentRequestCompleted NONCLUSTERED
			, RequestByUserId INT NOT NULL
			, DateCreated DATETIME NULL DEFAULT GETDATE()
			, DocumentId INT NULL INDEX IX_LetterTemplateDocumentDocumentId NONCLUSTERED
			, CONSTRAINT FK_LetterTemplateDocument_LetterTemplate FOREIGN KEY (LetterTemplateId) REFERENCES LetterTemplate(Id)
			, CONSTRAINT FK_LetterTemplateDocument_User FOREIGN KEY (RequestByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_LetterTemplateDocument_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
		);
		/**************************************************************************************************************************/

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;