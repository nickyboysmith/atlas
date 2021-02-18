/*
	SCRIPT: Create DocumentMarkedForDeleteCancelled Table
	Author: Nick Smith
	Created: 15/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_20.01_Create_DocumentMarkedForDeleteCancelled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentMarkedForDeleteCancelled Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentMarkedForDeleteCancelled'
		
		/*
		 *	Create DocumentMarkedForDeleteCancelled Table
		 */
		IF OBJECT_ID('dbo.DocumentMarkedForDeleteCancelled', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentMarkedForDeleteCancelled;
		END

		CREATE TABLE DocumentMarkedForDeleteCancelled(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId INT
			, RequestedByUserId INT
			, DateRequested DATETIME
			, DeleteAfterDate DATETIME
			, Note VARCHAR(200)
			, CancelledByUserId INT
			, DateDeleteCancelled DATETIME
			, CONSTRAINT FK_DocumentMarkedForDeleteCancelled_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentMarkedForDeleteCancelled_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_DocumentMarkedForDeleteCancelled_User1 FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;