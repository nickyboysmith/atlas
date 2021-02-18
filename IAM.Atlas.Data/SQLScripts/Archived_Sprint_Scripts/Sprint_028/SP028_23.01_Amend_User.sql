/*
 * SCRIPT: Add unique constraint on LoginId to User table
 * Author: Dan Hough
 * Created: 26/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_23.01_Amend_User.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add unique constraint on LoginId to User table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.[User]
		ADD UNIQUE (LoginId)
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;