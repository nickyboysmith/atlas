/*
	SCRIPT: Create ClientScheduledEmail Table
	Author: Dan Hough
	Created: 29/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_12.01_Create_ClientScheduledEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientScheduledEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientScheduledEmail'
		
		/*
		 *	Create ClientScheduledEmail Table
		 */
		IF OBJECT_ID('dbo.ClientScheduledEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientScheduledEmail;
		END

		CREATE TABLE ClientScheduledEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT 
			, ScheduledEmailId INT
			, CONSTRAINT FK_ClientScheduledEmail_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientScheduledEmail_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;