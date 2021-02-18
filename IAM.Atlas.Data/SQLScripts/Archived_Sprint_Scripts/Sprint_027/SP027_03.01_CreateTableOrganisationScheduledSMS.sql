/*
 * SCRIPT: Create Table OrganisationScheduledSMS
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_03.01_CreateTableOrganisationScheduledSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table OrganisationScheduledSMS';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationScheduledSMS'

		/*
		 *	Create OrganisationScheduledSMS Table
		 */
		IF OBJECT_ID('dbo.OrganisationScheduledSMS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationScheduledSMS;
		END

		CREATE TABLE OrganisationScheduledSMS(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId INT NOT NULL
			, OrganisationId INT NOT NULL
			, CONSTRAINT FK_OrganisationScheduledSMS_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES ScheduledSMS(Id)
			, CONSTRAINT FK_OrganisationScheduledSMS_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

