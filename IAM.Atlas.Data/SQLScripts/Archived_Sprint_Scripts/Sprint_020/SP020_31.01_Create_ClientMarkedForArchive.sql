/*
	SCRIPT: Create ClientMarkedForArchive Table
	Author: Dan Hough
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_31.01_Create_ClientMarkedForArchive.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientMarkedForArchive Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientMarkedForArchive'
		
		/*
		 *	Create ClientMarkedForArchive Table
		 */
		IF OBJECT_ID('dbo.ClientMarkedForArchive', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientMarkedForArchive;
		END

		CREATE TABLE ClientMarkedForArchive(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, RequestedByUserId INT NOT NULL
			, DateRequested datetime NOT NULL
			, ArchiveAfterDate datetime NOT NULL
			, CONSTRAINT FK_ClientMarkedForArchive_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientMarkedForArchive_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;