/*
	SCRIPT: Amend SP uspSendNewPassword
	Author: John Cocklin
	Created: 10/02/2017
*/
DECLARE @ScriptName VARCHAR(100) = 'SP033_16.02_Amend_uspSendNewPassword.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP uspSendNewPassword. Changed parameter LoginId to UserId';

/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;
GO

/*
	Drop the Procedure if it already exists
*/

IF OBJECT_ID('dbo.uspSendNewPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendNewPassword;
END
GO

	/*
		Create uspSendNewPassword
	*/
	CREATE PROCEDURE dbo.uspSendNewPassword @UserId INT
	AS
	BEGIN
		IF NOT EXISTS (SELECT u.id FROM [User] u WHERE Id = @UserId)
		BEGIN
			RAISERROR ('User Id does not exist',16,1) --?? severity
		END
		ELSE
		BEGIN
				DECLARE @LastLetterOfCurrentMonth CHAR(1)
				  , @FirstLetterOfCurrentMonth CHAR(1)
				  , @RandomNumberYear INT
				  , @MonthInt CHAR(2)
				  , @RandomNumber INT
				  , @Password INT
				  , @Lower INT = 100
				  , @Upper INT = 999
				  , @Lower2 INT = 1
				  , @Upper2 INT = 1000
				  , @RandomPassword CHAR(12)
				  , @RequestedByUserId INT
				  , @fromName VARCHAR(400)
				  , @fromEmailAddresses VARCHAR(400)
				  , @toEmailAddresses VARCHAR(400)
				  , @ccEmailAddresses VARCHAR(400)
				  , @bccEmailAddresses VARCHAR(400)
				  , @emailSubject VARCHAR(320)
				  , @emailContent VARCHAR(400)
				  , @asapFlag BIT
				  , @sendAfterDateTime DATETIME
				  , @emailServiceId INT
				  , @organisationId INT
				  , @Name VARCHAR(320);

			DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10);

			--setting variables for random password		
			SET @LastLetterOfCurrentMonth = lower(right(datename(mm, getdate()), 1)) -- Last letter of current month in lower case
			SET @FirstLetterOfCurrentMonth = upper(left(datename(mm, getdate()), 1)) --First letter of current month in upper case
			SET @RandomNumberYear = year(getdate()) - ROUND(((@Upper2 - @Lower2 - 1) * RAND() + @Lower2), 0) --Current year minus a random number between 1 and 1000
			SET @MonthInt = CONVERT(CHAR(2), GETDATE(), 101) -- Turns month in to double digit int
			SET @RandomNumber = ROUND(((@Upper - @Lower - 1) * RAND() + @Lower), 0) -- Random number between 100 and 999
		
			--Concatanate above to produce random password		
			SET @RandomPassword = @LastLetterOfCurrentMonth 
								+ @FirstLetterOfCurrentMonth 
								+ convert(VARCHAR(4), @RandomNumberYear) 
								+ @MonthInt 
								+ convert(VARCHAR(3), @RandomNumber) 
								+ '!';

			--Determine if user is linked to a client, and set email subject accordingly		
			SET @emailSubject = 'Atlas New Password';
			IF EXISTS (SELECT c.id 
					   FROM [User] u 
					   INNER JOIN client c ON u.id = c.UserId	
					   WHERE u.Id = @UserId)
			BEGIN
				SELECT @emailSubject = ISNULL(OSC.ClientApplicationDescription, @emailSubject),
					@organisationId = co.OrganisationId
				FROM [User] u
				INNER JOIN Client c ON u.id = c.UserId
				INNER JOIN ClientOrganisation co ON c.Id = co.ClientId
				INNER JOIN OrganisationSelfConfiguration OSC ON co.OrganisationId = OSC.OrganisationId
				WHERE u.Id = @UserId;
			END
			ELSE
			BEGIN
				SELECT @organisationId = ou.OrganisationId
				FROM [User] u
				INNER JOIN OrganisationUser ou ON u.id = ou.UserId
				WHERE u.Id = @UserId;							

			END

			SELECT @requestedByUserId = @UserId;

			SELECT @fromName = OSC.FromName,
				 @fromEmailAddresses = OSC.FromEmail	
			FROM OrganisationSystemConfiguration osc
			WHERE osc.OrganisationId = @organisationId

			SELECT TOP(1) @toEmailAddresses = Email
			FROM [User]
			WHERE Id = @UserId;		

			SELECT @Name = [Name]
			FROM [User]
			WHERE id = @UserId

			SET @emailContent = 'Hello ' + @Name 
				+ @NewLine + @NewLine + 'Your new password is: ' + @RandomPassword 
				+ @NewLine +'Please note,  this is a temporary password and you will have to change it when you login.' 
				+ @NewLine + @NewLine + 'Best Regards' 
				+ @NewLine + @NewLine + 'The Administration Team';

			--Set PasswordChangeRequired field to true		
			UPDATE dbo.[User]
			SET PasswordChangeRequired = 1
			WHERE Id = @UserId;

			--Save the password to the user table by calling spSetPassword		
			EXEC dbo.uspSetPassword @UserId, @RandomPassword;

			--Send email informing user of password change		
			EXEC dbo.uspSendEmail @requestedByUserId
								, @fromName
								, @fromEmailAddresses
								, @toEmailAddresses
								, @ccEmailAddresses
								, @bccEmailAddresses
								, @emailSubject
								, @emailContent
								, @asapFlag
								, @sendAfterDateTime
								, @emailServiceId
								, @organisationId;
		END
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP033_16.02_Amend_uspSendNewPassword.sql';
	EXEC dbo.uspScriptCompleted @ScriptName;
GO
