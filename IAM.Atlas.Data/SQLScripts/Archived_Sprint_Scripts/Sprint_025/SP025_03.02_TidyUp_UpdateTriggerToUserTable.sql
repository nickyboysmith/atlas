/*
	SCRIPT: Add update trigger to the User table
	Author: Robert Newnham
	Created: 24/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_03.02_TidyUp_UpdateTriggerToUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Tidy Up update trigger to the user table to handle emails on new user additions';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_NewUserEmail_UPDATE]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_NewUserEmail_UPDATE];
END
GO


	CREATE TRIGGER TRG_NewUserEmail_UPDATE ON [User] FOR UPDATE
	AS
	BEGIN
		/* NOTE The New User record send email is done in table OrganisationUser */
		DECLARE @LoginNotified BIT;
		DECLARE @UserId INT;

		SELECT @LoginNotified = I.LoginNotified FROM inserted I;
		SELECT @UserId = I.Id FROM inserted I;

		IF((ISNULL(@LoginNotified , 0)) = 0)
		BEGIN	
			EXEC dbo.[uspSendNewUserEmail] @userId = @UserId;
		END
	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP025_03.02_TidyUp_UpdateTriggerToUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
