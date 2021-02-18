/*
	SCRIPT: Amend insert trigger on the OrganisationUser table
	Author: Robert Newnham
	Created: 11/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_27.01_Amend_InsertTriggerOnOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationUser table to Check the User Has a Login Id';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
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
			/*************************************************************************************************************/
			
			--If The Organisation is a RA Org ensure on the Table ReferringAuthorityUser
			INSERT INTO dbo.ReferringAuthorityUser (ReferringAuthorityId, UserId, DateAdded, AddedByUserId) 
			SELECT DISTINCT
				RA.Id							AS ReferringAuthorityId
				, I.UserId						AS UserId
				, GETDATE()						AS DateAdded
				, dbo.udfGetSystemUserId()		AS AddedByUserId
			FROM INSERTED I
			INNER JOIN [dbo].[ReferringAuthority] RA		ON RA.[AssociatedOrganisationId] = I.[OrganisationId]
			LEFT JOIN dbo.ReferringAuthorityUser RAU		ON RAU.[ReferringAuthorityId] = RA.Id
															AND RAU.UserId = I.UserId
			WHERE RAU.Id IS NULL;

			/*************************************************************************************************************/

		END --END PROCESS
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_27.01_Amend_InsertTriggerOnOrganisationUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO