/*
	SCRIPT: Add Column To Table ClientOtherRequirement
	Author: Nick Smith
	Created: 29/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_01.02_AddOrganisationNotifiedColumnToTableClientOtherRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add OrganisationNotified Column To Table ClientOtherRequirement';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientOtherRequirement 
		ADD OrganisationNotified BIT NOT NULL DEFAULT 'False'
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END