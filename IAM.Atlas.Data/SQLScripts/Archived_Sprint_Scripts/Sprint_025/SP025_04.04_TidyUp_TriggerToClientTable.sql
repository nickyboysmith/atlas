/*
	SCRIPT: Tidy Up trigger to the Client table. Also Rename it. Also Remove Duplication of code in Update/Insert Trigger.
	Author: Robert Newnham
	Created: 24/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_04.04_TidyUp_TriggerToClientTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Tidy Up trigger to the Client table. Also Rename it. Also Remove Duplication of code in Update/Insert Trigger.';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewClientEmail_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_NewClientEmail_INSERT]; -- Remove Old Name
	END
GO
IF OBJECT_ID('dbo.[TRG_NewClientEmail_UPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_NewClientEmail_UPDATE]; -- Remove Old Name
	END
GO

IF OBJECT_ID('dbo.[TRG_Client_INSERTUPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Client_INSERTUPDATE];
	END
GO

	CREATE TRIGGER TRG_Client_INSERTUPDATE ON Client FOR INSERT, UPDATE
	AS
	BEGIN
		DECLARE @UserId INT;
		DECLARE @ClientId INT;

		SELECT @UserId = i.UserId FROM inserted i;
		SELECT @ClientId = i.Id FROM inserted i;
			
		EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;
	END
	GO
	/***END OF SCRIPT***/
	
DECLARE @ScriptName VARCHAR(100) = 'SP025_04.04_TidyUp_TriggerToClientTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO