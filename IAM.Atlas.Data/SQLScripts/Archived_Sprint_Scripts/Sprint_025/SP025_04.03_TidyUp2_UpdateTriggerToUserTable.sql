/*
	SCRIPT: Add update trigger to the User table. Also Rename the Trigger.
	Author: Robert Newnham
	Created: 24/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_04.03_TidyUp2_UpdateTriggerToUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Tidy Up update trigger to the user table to handle emails on new user additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewUserEmail_UPDATE]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_NewUserEmail_UPDATE]; -- Remove Old Name
END
GO

IF OBJECT_ID('dbo.[TRG_User_UPDATE]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_User_UPDATE];
END
GO


	CREATE TRIGGER TRG_User_UPDATE ON [User] FOR UPDATE
	AS
	BEGIN
		/* NOTE The New User record send email is done in table OrganisationUser */
		DECLARE @UserId INT;

		SELECT @UserId = I.Id FROM inserted I;
		
		EXEC dbo.[uspCheckUser] @userId = @UserId;

	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP025_04.03_TidyUp2_UpdateTriggerToUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
