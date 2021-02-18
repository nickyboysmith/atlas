/*
	SCRIPT: Add insert trigger to the OrganisationAdminUser table to insert entry into SystemSupportUser table
	Author: Paul Tuck
	Created: 23/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_06.01_AddInsertTriggerToOrganisationAdminUserToAddSystemSupportUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the OrganisationAdminUser table to insert entry into SystemSupportUser table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT];
		END
GO
		CREATE TRIGGER TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT ON OrganisationAdminUser FOR INSERT
AS

		
		DECLARE @AtlasSystemUserId INT;
		SELECT @AtlasSystemUserId = [AtlasSystemUserId] FROM [dbo].[SystemControl];


		INSERT INTO [dbo].[SystemSupportUser]
		(UserId, DateAdded, OrganisationId, AddedByUserId)
		SELECT  i.UserId, GETDATE(), i.OrganisationId, @AtlasSystemUserId
		FROM inserted i;


GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_06.01_AddInsertTriggerToOrganisationAdminUserToAddSystemSupportUser.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

