/*
 * SCRIPT: Alter OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 27/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_08.01_OrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD SpecialRequirementsToAdminsOnly BIT NOT NULL DEFAULT 'False'
			, SpecialRequirementsToSupportUsers BIT NOT NULL DEFAULT 'True'
			, SpecialRequirementsToAllUsers BIT NOT NULL DEFAULT 'False';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;