/*
	SCRIPT: Rename stored procedure spSendNewPassword uspSendNewPassword
	Author: Robert Newnham
	Created: 18/05/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP020_36.02_Rename_spSendNewPassword_uspSendNewPassword.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename stored procedure spSendNewPassword uspSendNewPassword';

/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;
GO

/*
	Drop the Procedure if it already exists
*/

IF OBJECT_ID('dbo.spSendNewPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spSendNewPassword;
END
GO
IF OBJECT_ID('dbo.uspSendNewPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendNewPassword;
END
GO

/*
	Create uspSendNewPassword
*/

CREATE PROCEDURE dbo.uspSendNewPassword @LoginId VARCHAR(320)
AS
BEGIN
	IF NOT EXISTS (SELECT u.LoginId FROM [User].id WHERE LoginId = @LoginId)
	BEGIN
		RAISERROR ('LoginId does not exist',16,1) --?? severity
	END
	ELSE
	BEGIN
		DECLARE @LastLetterOfCurrentMonth CHAR(1)
			,@FirstLetterOfCurrentMonth CHAR(1)
			,@RandomNumberYear INT
			,@MonthInt CHAR(2)
			,@RandomNumber INT
			,@Password INT
			,@Lower INT = 100
			,@Upper INT = 999
			,@Lower2 INT = 1
			,@Upper2 INT = 1000
			,@RandomPassword CHAR(12)
			,@RequestedByUserId INT
			,@fromName VARCHAR(400)
			,@fromEmailAddresses VARCHAR(400)
			,@toEmailAddresses VARCHAR(400)
			,@ccEmailAddresses VARCHAR(400)
			,@bccEmailAddresses VARCHAR(400)
			,@emailSubject VARCHAR(320)
			,@emailContent VARCHAR(400)
			,@asapFlag BIT
			,@sendAfterDateTime DATETIME
			,@emailServiceId INT
			,@organisationId INT
			,@Name VARCHAR(320)
			,@User_Id INT

		--setting variables for random password
		
		SET @LastLetterOfCurrentMonth = lower(right(datename(mm, getdate()), 1)) -- Last letter of current month in lower case
		SET @FirstLetterOfCurrentMonth = upper(left(datename(mm, getdate()), 1)) --First letter of current month in upper case
		SET @RandomNumberYear = year(getdate()) - ROUND(((@Upper2 - @Lower2 - 1) * RAND() + @Lower2), 0) --Current year minus a random number between 1 and 1000
		SET @MonthInt = CONVERT(CHAR(2), GETDATE(), 101) -- Turns month in to double digit int
		SET @RandomNumber = ROUND(((@Upper - @Lower - 1) * RAND() + @Lower), 0) -- Random number between 100 and 999
		
		--Concatanate above to produce random password
		
		SET @RandomPassword = @LastLetterOfCurrentMonth + @FirstLetterOfCurrentMonth + convert(VARCHAR(4), @RandomNumberYear) + @MonthInt + convert(VARCHAR(3), @RandomNumber) + '!'

		--Determine if user is linked to a client, and set email subject accordingly
		
		IF EXISTS (SELECT c.id FROM [User] u 
				   INNER JOIN client c ON u.id = c.UserId	
				   WHERE u.LoginId = @LoginId)
		BEGIN
			SELECT @emailSubject = OSC.ClientApplicationDescription
			FROM [User] u
			INNER JOIN Client c
				ON u.id = c.UserId
			INNER JOIN ClientOrganisation co
				ON c.Id = co.ClientId
			INNER JOIN OrganisationSelfConfiguration OSC
				ON co.Id = OSC.OrganisationId
			WHERE u.LoginId = @LoginId
		END

		ELSE

		BEGIN
			SELECT @emailSubject = 'Atlas New Password'
		END

		SELECT @requestedByUserId = id
		FROM [User]
		WHERE LoginId = @LoginId

		SELECT TOP 1 @fromName = OSC.FromName
		FROM [User] u
		INNER JOIN OrganisationUser ou
			ON u.id = ou.UserId
		INNER JOIN OrganisationSystemConfiguration OSC
			ON ou.OrganisationID = osc.OrganisationId
		WHERE u.LoginId = @LoginId

		SELECT TOP 1 @fromEmailAddresses = OSC.FromEmail
		FROM [User] u
		INNER JOIN OrganisationUser ou
			ON u.id = ou.UserId
		INNER JOIN OrganisationSystemConfiguration OSC
			ON ou.OrganisationID = osc.OrganisationId
		WHERE u.LoginId = @LoginId

		SELECT TOP 1 @toEmailAddresses = Email
		FROM [User]
		WHERE LoginId = @LoginId

		SET @ccEmailAddresses = NULL
		SET @bccEmailAddresses = NULL
		SET @sendAfterDateTime = NULL
		SET @emailServiceId = NULL
		SET @organisationId = NULL
		SET @asapFlag = NULL

		SELECT @Name = Name
		FROM [User]
		WHERE LoginId = @LoginId

		SET @emailContent = 'Hello ' + @Name 
			+ CHAR(13) + CHAR(10) + 
			'Your new password is: ' + @RandomPassword 
			+ CHAR(13) + CHAR(10) + 
			'Please note,  this is a temporary password and you will have to change it when you login.' 
			+ CHAR(13) + CHAR(10) + 
			'Best Regards' 
			+ CHAR(13) + CHAR(10) + 
			'The Administration Team'

		SELECT @User_Id = id
		FROM [User]
		WHERE LoginId = @LoginId

		--Set PasswordChangeRequired field to true
		
		UPDATE dbo.[User]
		SET PasswordChangeRequired = 1
		WHERE LoginId = @LoginId

		--Save the password to the user table by calling spSetPassword
		
		EXEC dbo.uspSetPassword @UserId = @User_Id
			,@Password = @RandomPassword

		--Send email informing user of password change
		
		EXEC dbo.uspSendEmail @requestedByUserId
			,@fromName
			,@fromEmailAddresses
			,@toEmailAddresses
			,@ccEmailAddresses
			,@bccEmailAddresses
			,@emailSubject
			,@emailContent
			,@asapFlag
			,@sendAfterDateTime
			,@emailServiceId
			,@organisationId 
	END
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_36.02_Rename_spSendNewPassword_uspSendNewPassword.sql';
	EXEC dbo.uspScriptCompleted @ScriptName;
GO
