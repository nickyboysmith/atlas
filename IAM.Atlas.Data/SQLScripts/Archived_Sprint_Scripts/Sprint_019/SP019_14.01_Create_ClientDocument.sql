/*
	SCRIPT: Create ClientDocument Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_14.01_Create_ClientDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientDocument'
		
		/*
		 *	Create ClientDocument Table
		 */
		IF OBJECT_ID('dbo.ClientDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientDocument;
		END

		CREATE TABLE ClientDocument(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, DocumentId int
			, CONSTRAINT FK_ClientDocument_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientDocument_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;