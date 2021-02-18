/*
 * SCRIPT: Alter OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 21/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_02.01_AlterTableDashboardMeterData_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD DORSClientExpiryDateDaysBeforeCourseBookingAllowed INT NOT NULL DEFAULT ((0))
			, DaysBeforeCourseBookingAllowed INT NOT NULL DEFAULT ((0));

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;