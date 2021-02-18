/*
 * SCRIPT: Alter Table Script for OrganisationSystemConfiguration, Add HoursToEmailCourseVenuesAfterCreation Column
 * Author: Nick Smith
 * Created: 18/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_41.02_Alter_OrganisationSystemConfigurationTableAddHoursToEmailCourseVenuesAfterCreation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Script for OrganisationSystemConfiguration, Add HoursToEmailCourseVenuesAfterCreation Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD
			HoursToEmailCourseVenuesAfterCreation INT DEFAULT 24
			
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

