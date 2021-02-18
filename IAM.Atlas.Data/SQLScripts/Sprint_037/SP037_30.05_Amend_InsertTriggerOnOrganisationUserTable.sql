/*
	SCRIPT: Amend insert trigger on the OrganisationUser table
	Author: Robert Newnham
	Created: 16/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_30.05_Amend_InsertTriggerOnOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationUser table to Check the User Has a Login Id';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[RG_OrganisationUser_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[RG_OrganisationUser_INSERT];
		END
	GO
	IF OBJECT_ID('dbo.[TRG_OrganisationUser_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_OrganisationUser_INSERT];
		END
	GO

	CREATE TRIGGER TRG_OrganisationUser_INSERT ON [OrganisationUser] FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'OrganisationUser', 'TRG_OrganisationUser_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
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

				EXEC dbo.[uspSendNewPassword] @InsertedUserId;
			END

			IF (@InsertedUserId IS NOT NULL)
			BEGIN
				EXEC uspEnsureDefaultAdminMenuAssignments @InsertedUserId
				EXEC uspEnsureDefaultMeterAssignments @InsertedUserId
			END

		END --END PROCESS
	GO
/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP037_30.05_Amend_InsertTriggerOnOrganisationUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO