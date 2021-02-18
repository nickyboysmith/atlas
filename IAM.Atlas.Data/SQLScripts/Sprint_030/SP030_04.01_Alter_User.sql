/*
 * SCRIPT: Add column to User
 * Author: Dan Hough
 * Created: 02/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_04.01_Alter_User.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to User';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.[User]
		ADD SecurePassword VARBINARY(255)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
