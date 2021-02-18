/*
	SCRIPT: Create ClientMarkedForDeleteCancelled Table
	Author: Dan Hough
	Created: 05/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_36.01_Create_ClientMarkedForDeleteCancelled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientMarkedForDeleteCancelled Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientMarkedForDeleteCancelled'
		
		/*
		 *	Create ClientMarkedForDeleteCancelled Table
		 */
		IF OBJECT_ID('dbo.ClientMarkedForDeleteCancelled', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientMarkedForDeleteCancelled;
		END

		CREATE TABLE ClientMarkedForDeleteCancelled(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT
			, RequestedByUserId INT
			, DateRequested DATETIME
			, DeleteAfterDate DATETIME
			, Note VARCHAR(200)
			, CancelledByUserId INT
			, DateDeleteCancelled DATETIME
			, CONSTRAINT FK_ClientMarkedForDeleteCancelled_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientMarkedForDeleteCancelled_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ClientMarkedForDeleteCancelled_User2 FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;