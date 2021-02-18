/*
	SCRIPT: Create DocumentMarkedForDelete Table
	Author: Dan Hough
	Created: 09/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_17.01_Create_DocumentMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentMarkedForDelete Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentMarkedForDelete'
		
		/*
		 *	Create DocumentMarkedForDelete Table
		 */
		IF OBJECT_ID('dbo.DocumentMarkedForDelete', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentMarkedForDelete;
		END

		CREATE TABLE DocumentMarkedForDelete(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId int
			, RequestedByUserId int
			, DateRequested datetime
			, DeleteAfterDate datetime
			, Note varchar(200)
			, CONSTRAINT FK_DocumentMarkedForDelete_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentMarkedForDelete_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;