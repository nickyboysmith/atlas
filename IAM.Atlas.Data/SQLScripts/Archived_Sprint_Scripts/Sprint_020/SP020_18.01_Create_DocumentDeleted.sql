/*
	SCRIPT: Create DocumentDeleted Table
	Author: Dan Hough
	Created: 09/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_18.01_Create_DocumentDeleted.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentDeleted Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentDeleted'
		
		/*
		 *	Create DocumentDeleted Table
		 */
		IF OBJECT_ID('dbo.DocumentDeleted', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentDeleted;
		END

		CREATE TABLE DocumentDeleted(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId int
			, RequestedByUserId int
			, DateRequested datetime
			, DateDeleted datetime
			, Note varchar(200)
			, CONSTRAINT FK_DocumentDeleted_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentDeleted_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;