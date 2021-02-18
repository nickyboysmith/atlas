/*
	SCRIPT: Amend Stored Procedure uspSendNewUserEmail. Ensure User has Login Id
	Author: Robert Newnham
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_14.05_Amend_uspSendNewUserEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored Procedure uspSendNewUserEmail. Ensure User has Login Id';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendNewUserEmail', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendNewUserEmail;
END		
GO

	/*
		Create uspSendNewUserEmail
	*/
	CREATE PROCEDURE uspSendNewUserEmail
	(
		@clientId INT = NULL,
		@userId INT = NULL
	)
	AS
	BEGIN
		/*
			This Stored Procedure is called from the following Triggers:
					TRG_NewClientEmail_INSERT
					TRG_NewUserEmail_INSERT <---- no longer!  Moved to TRG_NewOrganisationUser_Insert
					TRG_NewClientEmail_UPDATE
					TRG_NewUserEmail_UPDATE 
		*/
		DECLARE @loginNotified BIT;
		DECLARE @userName VARCHAR(20);
		DECLARE @loginId VARCHAR(20);
		DECLARE @emailTitle VARCHAR(320);
		DECLARE @emailBody VARCHAR(4000);
		DECLARE @toAddress VARCHAR(20);
		DECLARE @fromAddress VARCHAR(50);
		DECLARE @orgId INT;
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @IsSystemsAdmin BIT = 'False';
		DECLARE @fromName VARCHAR(320);
		DECLARE @requestedByUserId INT = [dbo].[udfGetSystemUserId]();
		
		IF (ISNULL(@userId, 0)) > 0
		BEGIN
			--PRINT '@userId: ' + CAST(@userId AS VARCHAR(10));
			SELECT 
				@loginNotified = U.LoginNotified
				, @userName = U.Name
				, @loginId = U.LoginId
				, @toAddress = U.Email
				, @orgId = OU.OrganisationId
				, @IsSystemsAdmin = (CASE WHEN SAU.ID IS NULL THEN 'False' ELSE 'True' END)		
			FROM [dbo].[User] U
			INNER JOIN [dbo].[OrganisationUser] OU ON OU.UserId = U.Id
			LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = U.Id
			WHERE U.Id = @userId;

		END --IF (ISNULL(@userId, 0)) > 0
		ELSE IF (ISNULL(@clientId, 0)) > 0
		BEGIN
			--PRINT '@clientId: ' + CAST(@clientId AS VARCHAR(10));
			SELECT TOP 1 --Get "TOP 1" Just in case the Client has more than one Email Address
				@loginNotified = U.LoginNotified
				, @userName = (CASE WHEN LEN(ISNULL(C.DisplayName,'')) > 0 THEN C.DisplayName
								ELSE LTRIM(
										RTRIM(
											(ISNULL(C.[Title],'') + ' ' + ISNULL(C.[FirstName],'') + ' ' + ISNULL(C.[Surname],''))
											)
										)
								END )
				, @loginId = U.LoginId
				, @userId = U.Id
				, @toAddress = (CASE WHEN LEN(ISNULL(U.Email,'')) > 0 THEN U.Email ELSE E.[Address] END)
				, @orgId = CO.OrganisationId	
				, @IsSystemsAdmin = (CASE WHEN SAU.ID IS NULL THEN 'False' ELSE 'True' END)			   	
			FROM [dbo].[Client] C
			INNER JOIN [dbo].[User] U ON U.Id = C.UserId
			INNER JOIN [dbo].[ClientOrganisation] CO ON CO.ClientId = C.Id
			LEFT JOIN [dbo].[ClientEmail] CE ON CE.[ClientId] = C.Id
			LEFT JOIN [dbo].[Email] E ON E.Id = CE.[EmailId]
			LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = U.Id
			WHERE C.Id = @clientId;
		END --ELSE IF (ISNULL(@clientId, 0)) > 0
				
		--Check Login Id is Valid
		IF (LEN(ISNULL(@loginId,'')) <=0 )
		BEGIN
			EXEC uspCreateUserLoginId @UserId = @userId;
			SELECT @loginNotified = LoginNotified
				, @loginId = LoginId 
			FROM [User] 
			WHERE Id = @userId;		
		END

		IF (@loginNotified != 'True')
		BEGIN
			--PRINT 'LOGIN NOT NOTIFIED';
			SELECT 
				@emailTitle = (CASE WHEN (ISNULL(@clientId, 0)) > 0
									THEN COALESCE(NULLIF(OSC.ClientApplicationDescription,''), 'Driver / Rider Improvement Schemes')
									ELSE 'Atlas Login Details'
									END)
				, @emailBody = 'Hello ' + @userName + ','
							+ @NewLine + 'Please use "' + @loginId + '" to login into our application.'
							+ @NewLine + 'You will be sent a new password in a separate email. You will have to change the Password when you first login.'
							+ @NewLine + @NewLine + 'Best Regards'
							+ @NewLine + @NewLine + 'The Administration Team'
				, @fromAddress = (CASE WHEN LEN(ISNULL(OSCon.FromEmail,'')) > 0 THEN OSCon.FromEmail ELSE SC.[AtlasSystemFromEmail] END)
				, @fromName = (CASE WHEN LEN(ISNULL(OSCon.FromName,'')) > 0 THEN OSCon.FromName ELSE SC.[AtlasSystemFromName] END)
			FROM [dbo].[SystemControl] SC
			LEFT JOIN [dbo].[OrganisationSelfConfiguration] OSC ON OSC.OrganisationId = @orgId
			LEFT JOIN [dbo].[OrganisationSystemConfiguration] OSCon ON OSCon.OrganisationId = @orgId
			WHERE SC.Id = 1
			;
		
			BEGIN TRY
					EXEC uspSendEmail @toEmailAddresses = @toAddress
									, @emailSubject = @emailTitle
									, @emailContent = @emailBody
									, @organisationId = @orgId
									, @fromEmailAddresses = @fromAddress
									, @requestedByUserId = @requestedByUserId
									, @fromName = @FromName;

					UPDATE [dbo].[User] 
					SET LoginNotified = 'True'
					WHERE Id = @userId;
			END TRY

			BEGIN CATCH
			END CATCH	
		END -- IF (@LoginNotified != 'True')
		
	END
	GO
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP026_14.05_Amend_uspSendNewUserEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


