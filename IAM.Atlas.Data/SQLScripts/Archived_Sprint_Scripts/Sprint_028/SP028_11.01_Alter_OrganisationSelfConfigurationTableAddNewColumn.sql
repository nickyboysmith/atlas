/*
 * SCRIPT: Alter Table Script for OrganisationSelfConfiguration, Add OnlineBookingCutOffDaysBeforeCourse Column
 * Author: Robert Newnham
 * Created: 21/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_11.01_Alter_OrganisationSelfConfigurationTableAddNewColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Script for OrganisationSelfConfiguration, Add OnlineBookingCutOffDaysBeforeCourse Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD
			OnlineBookingCutOffDaysBeforeCourse INT DEFAULT 2
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

