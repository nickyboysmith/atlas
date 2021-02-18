/*
 * SCRIPT: Change New Column to Table PostCodeInformation
 * Author: Robert Newnham
 * Created: 12/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.01_AmendTablePostCodeInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'New Column Table PostCodeInformation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[PostCodeInformation]
		ADD PostCodeNoSpaces VARCHAR(50);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;