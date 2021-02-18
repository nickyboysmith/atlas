/*
	SCRIPT: Add insert trigger to the Client table
	Author: Dan Murray
	Created: 16/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_37.03_Fix_AddInsertTriggerToClientTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the client table to handle emails on new client additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewClientEmail_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewClientEmail_INSERT];
		END
GO
		CREATE TRIGGER TRG_NewClientEmail_INSERT ON Client FOR INSERT
AS
		DECLARE @UserId INT;
		DECLARE @ClientId INT;

		SELECT @UserId = i.UserId FROM inserted i;
		SELECT @ClientId = i.Id FROM inserted i;

		IF((ISNULL(@UserId , 0)) > 0)
			BEGIN	
				EXEC dbo.[uspSendNewUserEmail] @clientId = @ClientId, @userId = 0;
			END
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP020_37.03_Fix_AddInsertTriggerToClientTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO