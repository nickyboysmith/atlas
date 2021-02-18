/*
	SCRIPT: Alter Table OrganisationSMSTemplateMessage Code to Varchar(20)
	Author: Nick Smith
	Created: 02/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_16.01_AlterTableOrganisationSMSTemplateMessageAlterColumnCode.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSMSTemplateMessage Code to Varchar(20)';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE OrganisationSMSTemplateMessage
		ALTER COLUMN Code VARCHAR(20);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;