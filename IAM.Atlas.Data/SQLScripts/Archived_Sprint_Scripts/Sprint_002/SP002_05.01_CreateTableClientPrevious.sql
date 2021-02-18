


/*
	SCRIPT: Create ClientPreviousId Table
	Author: Robert Newnham
	Created: 05/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_05.01_CreateTableClientPrevious.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientPreviousId'

		/*
			Create Table ClientPreviousId
		*/
		IF OBJECT_ID('dbo.ClientPreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientPreviousId;
		END

		CREATE TABLE ClientPreviousId(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int NOT NULL
			, PreviousClientId int NOT NULL
			, CONSTRAINT FK_ClientPreviousId_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

