/*
 * SCRIPT: Alter ClientEmailTemplateEmail
 * Author: Dan Hough
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_34.01_AlterTableClientEmailTemplateEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ClientEmailTemplateEmail';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.ClientEmailTemplateEmail
		SET AddedByUserId = dbo.udfGetSystemUserId()
		WHERE AddedByUserId IS NULL;

		ALTER TABLE dbo.ClientEmailTemplateEmail
		ALTER COLUMN AddedByUserId INT NOT NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
