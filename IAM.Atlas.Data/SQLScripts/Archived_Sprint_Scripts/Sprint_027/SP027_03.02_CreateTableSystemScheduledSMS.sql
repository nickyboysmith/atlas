/*
 * SCRIPT: Create Table SystemScheduledSMS
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_03.02_CreateTableSystemScheduledSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table SystemScheduledSMS';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemScheduledSMS'

		/*
		 *	Create SystemScheduledSMS Table
		 */
		IF OBJECT_ID('dbo.SystemScheduledSMS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemScheduledSMS;
		END

		CREATE TABLE SystemScheduledSMS(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId INT NOT NULL
			, CONSTRAINT FK_SystemScheduledSMS_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES ScheduledSMS(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

