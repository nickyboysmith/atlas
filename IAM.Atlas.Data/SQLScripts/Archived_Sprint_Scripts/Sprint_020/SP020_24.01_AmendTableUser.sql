/*
 * SCRIPT: Alter Table Users
 * Author: Dan Murray
 * Created: 13/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_24.01_AmendTableUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to Users table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF NOT EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'LoginNotified' 
					AND Object_ID = Object_ID(N'User'))
		BEGIN
			ALTER TABLE dbo.[User]
				ADD LoginNotified bit DEFAULT 0
		END
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;