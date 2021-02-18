/*
	SCRIPT: Amend insert trigger to the OrganisationAdminUser table to insert entry into SystemSupportUser table
	Author: Robert Newnham
	Created: 15/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_28.02_AddInsertTriggerToOrganisationAdminUserToAddSystemSupportUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationAdminUser table to insert entry into SystemSupportUser table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT];
	END
GO

IF OBJECT_ID('dbo.[TRG_OrganisationAdminUser_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationAdminUser_INSERT];
	END
GO

	CREATE TRIGGER TRG_OrganisationAdminUser_INSERT ON OrganisationAdminUser FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'OrganisationAdminUser', 'TRG_OrganisationAdminUser_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @UserId INT;

			INSERT INTO [dbo].[SystemSupportUser] (UserId, DateAdded, OrganisationId, AddedByUserId)
			SELECT  I.UserId, GETDATE(), I.OrganisationId, dbo.udfGetSystemUserId()
			FROM INSERTED I;

			SELECT @UserId = I.UserId
			FROM INSERTED I;

			IF (@UserId IS NOT NULL)
			BEGIN
				EXEC uspEnsureDefaultAdminMenuAssignments @UserId
			END

		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_28.02_AddInsertTriggerToOrganisationAdminUserToAddSystemSupportUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

