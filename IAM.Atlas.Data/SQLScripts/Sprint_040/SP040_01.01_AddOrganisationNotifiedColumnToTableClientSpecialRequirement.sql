/*
	SCRIPT: Add Column To Table ClientSpecialRequirement
	Author: Nick Smith
	Created: 29/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_01.01_AddOrganisationNotifiedColumnToTableClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add OrganisationNotified Column To Table ClientSpecialRequirement';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientSpecialRequirement 
		ADD OrganisationNotified BIT NOT NULL DEFAULT 'False'
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END