/*
	SCRIPT: Create ClientScheduledSMS Table
	Author: Dan Hough
	Created: 29/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_13.01_Create_ClientScheduledSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientScheduledSMS Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientScheduledSMS'
		
		/*
		 *	Create ClientScheduledSMS Table
		 */
		IF OBJECT_ID('dbo.ClientScheduledSMS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientScheduledSMS;
		END

		CREATE TABLE ClientScheduledSMS(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT 
			, ScheduledSMSId INT
			, CONSTRAINT FK_ClientScheduledSMS_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientScheduledSMS_ScheduledSMSId FOREIGN KEY (ScheduledSMSId) REFERENCES ScheduledSMS(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;