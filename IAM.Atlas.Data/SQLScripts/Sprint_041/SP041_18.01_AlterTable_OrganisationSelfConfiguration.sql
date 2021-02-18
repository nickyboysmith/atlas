/*
 * SCRIPT: Alter OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 27/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_18.01_AlterTable_OrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD TrainerNotificationBCCEmailAddress VARCHAR(320);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
