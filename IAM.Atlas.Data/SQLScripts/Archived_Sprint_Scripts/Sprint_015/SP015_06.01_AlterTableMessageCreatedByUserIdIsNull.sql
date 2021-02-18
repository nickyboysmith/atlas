/*
	SCRIPT: Alter Table Message
	Author: Nick Smith
	Created: 27/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_06.01_AlterTableMessageCreatedByUserIdIsNull.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Message, CreatedByUserId Can Be Null';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [Message] ALTER COLUMN CreatedByUserId INT NULL;
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;