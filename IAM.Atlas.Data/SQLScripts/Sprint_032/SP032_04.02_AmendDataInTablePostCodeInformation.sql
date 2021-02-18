/*
 * SCRIPT: Amend Data in Table PostCodeInformation
 * Author: Robert Newnham
 * Created: 12/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP032_04.02_AmendDataInTablePostCodeInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Data in Table PostCodeInformation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE [dbo].[PostCodeInformation]
		SET PostCodeNoSpaces = REPLACE(PostCode, ' ','');
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;