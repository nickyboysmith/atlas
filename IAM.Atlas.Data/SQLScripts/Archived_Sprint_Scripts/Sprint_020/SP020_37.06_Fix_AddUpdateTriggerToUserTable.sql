/*
	SCRIPT: Add update trigger to the User table
	Author: Dan Murray
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_37.06_Fix_AddUpdateTriggerToUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to the user table to handle emails on new user additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewUserEmail_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewUserEmail_UPDATE];
		END
GO
		CREATE TRIGGER TRG_NewUserEmail_UPDATE ON [User] FOR UPDATE
AS
		DECLARE @LoginNotified BIT;
		DECLARE @Type CHAR(1);
		DECLARE @UserId INT;

		IF EXISTS (SELECT * FROM inserted)
				IF EXISTS (SELECT * FROM deleted)
						SELECT @Type = 'U'
				ELSE
						SELECT @Type = 'I'
		ELSE
			SELECT @Type = 'D'

		IF(@Type = 'U')
		BEGIN
			SELECT @LoginNotified = I.LoginNotified FROM inserted I;
			SELECT @UserId = I.Id FROM inserted I;

			IF((ISNULL(@LoginNotified , 0)) = 0)
				BEGIN	
					EXEC dbo.[uspSendNewUserEmail] @userId = @UserId, @clientId = 0;
				END
		END
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP020_37.06_Fix_AddUpdateTriggerToUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO