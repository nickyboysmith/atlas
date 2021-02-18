/*
 * SCRIPT: Change SecurePassword Column and table User
 * Author: Robert Newnham
 * Created: 17/02/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP033_32.01_AmendTableUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change SecurePassword Column and table User';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.[User]
		ALTER COLUMN SecurePassword VARBINARY(200)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;