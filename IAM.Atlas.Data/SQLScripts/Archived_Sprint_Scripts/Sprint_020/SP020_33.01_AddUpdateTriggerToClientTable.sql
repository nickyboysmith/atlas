/*
	SCRIPT: Add update trigger to the Client table
	Author: Dan Murray
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_33.01_AddUpdateTriggerToClientTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to the client table to handle emails on new client additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewClientEmail_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewClientEmail_UPDATE];
		END
GO

	CREATE TRIGGER TRG_NewClientEmail_UPDATE ON Client FOR INSERT
	AS
		DECLARE @UserId INT;
		DECLARE @Type CHAR(1);
		DECLARE @ClientId INT;

		IF EXISTS (SELECT * FROM inserted)
				IF EXISTS (SELECT * FROM deleted)
						SELECT @Type = 'U'
				ELSE
						SELECT @Type = 'I'
		ELSE
			SELECT @Type = 'D'

		IF(@Type = 'U')
		BEGIN
			SELECT @UserId = i.UserId FROM inserted i;
			SELECT @ClientId = i.Id FROM inserted i;

			IF((ISNULL(@UserId , 0)) > 0)
				BEGIN	
					EXEC dbo.[uspSendNewUserEmail] @clientId = @ClientId, @userId = 0;
				END
		END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP020_33.01_AddUpdateTriggerToClientTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO