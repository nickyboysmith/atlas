/*
	SCRIPT: Add insert trigger to the User table
	Author: Paul Tuck
	Created: 5/7/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_38.01_Drop_AddInsertTriggerToUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the user table to handle emails on new user additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewUserEmail_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewUserEmail_INSERT];
		END
GO
		
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_38.01_Drop_AddInsertTriggerToUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO