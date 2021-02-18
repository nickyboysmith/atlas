/*
	SCRIPT: Amend insert trigger to the OrganisationUser table
	Author: Robert Newnham
	Created: 24/8/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_04.02_Amend_InsertTriggerToOrganisationUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the OrganisationUser table Adding Configuration Settings';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewOrganisationUser_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_NewOrganisationUser_Insert];
	END
GO
	CREATE TRIGGER TRG_NewOrganisationUser_Insert ON [OrganisationUser] FOR INSERT
	AS
		DECLARE @InsertedUserId INT;

		SELECT @InsertedUserId = I.UserId FROM inserted I;
		
		EXEC dbo.[uspCheckUser] @userId = @InsertedUserId;

		/****************************************************************************/
	GO
/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP025_04.02_Amend_InsertTriggerToOrganisationUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO