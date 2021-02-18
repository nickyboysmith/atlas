/*
	SCRIPT: Create ClientDORSNotification Table
	Author: Dan Murray
	Created: 31/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_01.01_Create_ClientDORSNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientDORSNotification Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientDORSNotification'
		
		/*
		 *	Create ClientDORSNotification Table
		 */
		IF OBJECT_ID('dbo.ClientDORSNotification', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientDORSNotification;
		END

		CREATE TABLE ClientDORSNotification(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT
			, LicenceNumberUsed VARCHAR(40) 
			, DateTimeDORSNotified DATETIME
			, NotificationType  VARCHAR(20)
			, CONSTRAINT FK_ClientDORSNotification_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;