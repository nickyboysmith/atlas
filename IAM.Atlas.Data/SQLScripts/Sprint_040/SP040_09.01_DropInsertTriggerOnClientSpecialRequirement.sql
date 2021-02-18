/*
	SCRIPT: Drop Insert Trigger On ClientSpecialRequirement
	Author: Nick Smith
	Created: 30/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_09.01_DropInsertTriggerOnClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop Insert Trigger On ClientSpecialRequirement';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF OBJECT_ID('dbo.[TRG_ClientSpecialRequirement_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER [dbo].[TRG_ClientSpecialRequirement_INSERT];
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
