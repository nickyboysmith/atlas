/*
	SCRIPT: Add insert trigger to the OrganisationUser table
	Author: Paul Tuck
	Created: 5/7/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_39.01_Create_InsertTriggerToOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the OrganisationUser table to handle emails on new OrganisationUser additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewOrganisationUser_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NewOrganisationUser_Insert];
		END
GO
		CREATE TRIGGER TRG_NewOrganisationUser_Insert ON [OrganisationUser] FOR INSERT
AS
		DECLARE @LoginNotified BIT;
		DECLARE @InsertedUserId INT;

		SELECT @InsertedUserId = I.UserId FROM inserted I;
		SELECT @LoginNotified = LoginNotified FROM [User] WHERE Id = @InsertedUserId;
		

		IF((ISNULL(@LoginNotified , 0)) = 0)
			BEGIN
				EXEC dbo.[uspSendNewUserEmail] @userId = @InsertedUserId, @clientId = 0;
			END
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_39.01_Create_InsertTriggerToOrganisationUserTable';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO
DECLARE @ScriptName VARCHAR(100) = 'SP022_39.01_Create_InsertTriggerToOrganisationUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO