/*
	SCRIPT: Create DocumentPrintQueue Table
	Author: Robert Newnham
	Created: 14/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_11.02_CreateDocumentPrintQueueTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentPrintQueue Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentPrintQueue'
		
		/*
		 *	Create DocumentPrintQueue Table
		 */
		IF OBJECT_ID('dbo.DocumentPrintQueue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentPrintQueue;
		END

		CREATE TABLE DocumentPrintQueue(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DocumentPrintQueueOrganisationId NONCLUSTERED
			, DocumentId INT NOT NULL INDEX IX_DocumentPrintQueueDocumentId NONCLUSTERED
			, QueueInfo VARCHAR(100) NULL
			, CreatedByUserId INT NOT NULL INDEX IX_DocumentPrintQueueCreatedByUserId NONCLUSTERED
			, DateCreated DateTime NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_DocumentPrintQueue_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_DocumentPrintQueue_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentPrintQueue_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END