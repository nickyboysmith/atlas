/*
 * SCRIPT: Alter Table Script for OrganisationSelfConfiguration, Add AllowAutoEmailCourseVenuesOnCreationToBeSent, MinutesToHoldOnlineUnpaidCourseBookings and MaximumMinutesToLockClientsFor Columns
 * Author: Nick Smith
 * Created: 18/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_41.01_Alter_OrganisationSelfConfigurationTableAddAllowAutoEmailMinutesToHoldMaximumMinutesToLockForColumns.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Script for OrganisationSelfConfiguration, Add AllowAutoEmailCourseVenuesOnCreationToBeSent, MinutesToHoldOnlineUnpaidCourseBookings and MaximumMinutesToLockClientsFor Columns';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD
			AllowAutoEmailCourseVenuesOnCreationToBeSent BIT DEFAULT 'False',
			MinutesToHoldOnlineUnpaidCourseBookings INT DEFAULT 15,
			MaximumMinutesToLockClientsFor INT DEFAULT 120
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

