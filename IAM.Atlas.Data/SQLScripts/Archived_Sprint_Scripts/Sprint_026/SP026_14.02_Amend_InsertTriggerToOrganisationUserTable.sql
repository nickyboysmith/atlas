/*
	SCRIPT: Amend insert trigger to the OrganisationUser table
	Author: Robert Newnham
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_14.02_Amend_InsertTriggerToOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationUser table to Check the User Has a Login Id';

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
		
		--Check Login Id is Valid
		IF (LEN(ISNULL(@NewLoginId,'')) <=0 )
		BEGIN
			EXEC uspCreateUserLoginId @UserId = @InsertedUserId;
			SELECT @LoginNotified = LoginNotified, @NewLoginId = LoginId FROM [User] WHERE Id = @InsertedUserId;
		END

		IF((ISNULL(@LoginNotified , 0)) = 0)
		BEGIN
			EXEC dbo.[uspSendNewUserEmail] @userId = @InsertedUserId, @clientId = 0;

			EXEC dbo.[uspSendNewPassword] @LoginId = @NewLoginId;
		END
	GO
/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP026_14.02_Amend_InsertTriggerToOrganisationUserTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO