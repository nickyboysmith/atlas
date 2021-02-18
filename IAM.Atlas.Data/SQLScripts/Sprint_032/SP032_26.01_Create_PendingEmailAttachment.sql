/*
 * SCRIPT: Create PendingEmailAttachment Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_26.01_Create_PendingEmailAttachment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PendingEmailAttachment Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PendingEmailAttachment'
		
		/*
		 *	Create PendingEmailAttachment Table
		 */
		IF OBJECT_ID('dbo.PendingEmailAttachment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PendingEmailAttachment;
		END

		CREATE TABLE PendingEmailAttachment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SameEmailAs_PendingEmailAttachmentId INT NULL
			, DocumentId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_PendingEmailAttachment_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_PendingEmailAttachment_PendingEmailAttachment FOREIGN KEY (SameEmailAs_PendingEmailAttachmentId) REFERENCES PendingEmailAttachment(Id)
			, INDEX IX_PendingEmailAttachment NONCLUSTERED (SameEmailAs_PendingEmailAttachmentId)
			, INDEX IX_PendingEmailAttachmentDocumentId NONCLUSTERED (DocumentId)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;