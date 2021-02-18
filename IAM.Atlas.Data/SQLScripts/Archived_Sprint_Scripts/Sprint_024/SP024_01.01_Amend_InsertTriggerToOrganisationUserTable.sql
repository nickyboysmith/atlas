/*
	SCRIPT: Amend insert trigger to the OrganisationUser table
	Author: Dan Murray
	Created: 28/7/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_01.01_Amend_InsertTriggerToOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationUser table to handle emails on new OrganisationUser additions and send new password email';

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
		DECLARE @NewLoginId VARCHAR(320);

		SELECT @InsertedUserId = I.UserId FROM inserted I;
		SELECT @LoginNotified = LoginNotified, @NewLoginId = LoginId FROM [User] WHERE Id = @InsertedUserId;
		

		IF((ISNULL(@LoginNotified , 0)) = 0)
			BEGIN
				EXEC dbo.[uspSendNewUserEmail] @userId = @InsertedUserId, @clientId = 0;

				EXEC dbo.[uspSendNewPassword] @LoginId = @NewLoginId;
			END
GO
/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP024_01.01_Amend_InsertTriggerToOrganisationUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO