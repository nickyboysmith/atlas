/*
 * SCRIPT: Alter OrganisationEmailTemplateMessage
 * Author: Dan Hough
 * Created: 27/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_14.04_AlterTableOrganisationEmailTemplateMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationEmailTemplateMessage';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationEmailTemplateMessage
		ALTER COLUMN Content VARCHAR(4000);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
