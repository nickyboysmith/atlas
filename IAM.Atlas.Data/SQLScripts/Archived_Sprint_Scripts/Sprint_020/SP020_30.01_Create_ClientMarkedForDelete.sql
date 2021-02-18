/*
	SCRIPT: Create ClientMarkedForDelete Table
	Author: Dan Hough
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_30.01_Create_ClientMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientMarkedForDelete Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientMarkedForDelete'
		
		/*
		 *	Create ClientMarkedForDelete Table
		 */
		IF OBJECT_ID('dbo.ClientMarkedForDelete', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientMarkedForDelete;
		END

		CREATE TABLE ClientMarkedForDelete(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, RequestedByUserId INT NOT NULL
			, DateRequested datetime NOT NULL
			, DeleteAfterDate datetime NOT NULL
			, Note VARCHAR(200) NULL
			, CONSTRAINT FK_ClientMarkedForDelete_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientMarkedForDelete_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;