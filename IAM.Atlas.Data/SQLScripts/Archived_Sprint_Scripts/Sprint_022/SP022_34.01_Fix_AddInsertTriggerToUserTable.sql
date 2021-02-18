/*
	SCRIPT: Add insert trigger to the User table
	Author: Paul Tuck
	Created: 4/7/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_34.01_Fix_AddInsertTriggerToUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the user table to handle emails on new user additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewUserEmail_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewUserEmail_INSERT];
		END
GO
		CREATE TRIGGER TRG_NewUserEmail_INSERT ON [User] FOR INSERT
AS
		DECLARE @LoginNotified BIT;
		DECLARE @InsertedUserId INT;

		SELECT @LoginNotified = I.LoginNotified FROM inserted I;
		SELECT @InsertedUserId = I.Id FROM inserted I;

		IF((ISNULL(@LoginNotified , 0)) = 0)
			BEGIN	
				EXEC dbo.[uspSendNewUserEmail] @userId = @InsertedUserId, @clientId = 0;
			END
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_34.01_Fix_AddInsertTriggerToUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO