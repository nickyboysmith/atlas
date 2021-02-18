/*
	SCRIPT: Add insert trigger to the User table
	Author: Dan Murray
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_28.01_AddInsertTriggerToUserTable.sql';
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
		DECLARE @UserId INT;

		SELECT @LoginNotified = I.LoginNotified FROM inserted I;
		SELECT @UserId = I.Id FROM inserted I;

		IF((ISNULL(@LoginNotified , 0)) = 0)
			BEGIN	
				EXEC dbo.[uspSendNewUserEmail] @userId = @UserId, @clientId = 0;
			END
GO 
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP020_28.01_AddInsertTriggerToUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO