/*
	SCRIPT: Create Stored Procedure to send new user emails
	Author: Dan Murray
	Created: 13/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_37.02_Fix_Create_uspSendNewUserEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored Procedure to send new user emails';
		
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
	@clientId INT,
	@userId INT
)
AS
BEGIN
/*
	This Stored Procedure is called from the following Triggers:
			TRG_NewClientEmail_INSERT
			TRG_NewUserEmail_INSERT
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
	DECLARE @Uid INT;

	IF @clientId > 0
		BEGIN
			SELECT @loginNotified = U.LoginNotified,
				   @userName = U.Name,
				   @loginId = U.LoginId,
				   @emailTitle = COALESCE(NULLIF(OSC.ClientApplicationDescription,''), 'Driver / Rider Improvement Schemes'),
				   @emailBody = 'Hello' + U.Name + ',' + CHAR(13) + 
								'Please use "' + U.LoginId + '" to login into our application. ' + 
								'You will be sent a new password in a separate email. You will have to change the Password when you first login.' + CHAR(13) + 
								'Best Regards' + CHAR(13) + 
								'The Administration Team',
				   @toAddress = U.Email,
				   @fromAddress = OSCon.FromEmail,
				   @orgId = CO.OrganisationId,
				   @Uid = U.Id
				   	
			FROM [dbo].[Client] C
			JOIN [dbo].[User] U
			ON C.UserId = U.Id
			JOIN [dbo].[ClientOrganisation] CO
			ON CO.ClientId = C.Id
			JOIN [dbo].[OrganisationSelfConfiguration] OSC
			ON OSC.OrganisationId = CO.OrganisationId
			JOIN [dbo].[OrganisationSystemConfiguration] OSCon
			ON OSCon.OrganisationId = CO.OrganisationId 
			WHERE C.Id = @clientId;

			If(@LoginNotified = 0)
				BEGIN

				-- //TODO Insert correct value for  @requestedByUserId once that user story has been completed
					BEGIN TRY
							EXEC uspSendEmail @toEmailAddresses=@toAddress,
											  @fromEmailAddresses=@fromAddress,
											  @emailSubject=@emailTitle,
											  @emailContent=@emailBody,
											  @organisationId=@orgId,
											  @requestedByUserId=1;	
							UPDATE [dbo].[User] 
							SET LoginNotified = 'true'
							WHERE Id = @userId;
					END TRY

					BEGIN CATCH
					END CATCH					
				END
		END

	IF @userId > 0
		BEGIN
			SELECT @loginNotified = U.LoginNotified,
				   @userName = U.Name,
				   @loginId = U.LoginId,
				   @emailTitle = 'Atlas Login Details',
				   @emailBody = 'Hello' + U.Name + ',' + CHAR(13) + 
								'Please use "' + U.LoginId + '" to login into Atlas. ' + 
								'You will be sent a new password in a separate email. You will have to change the Password when you first login.' + CHAR(13) + 
								'Best Regards' + CHAR(13) + 
								'The Administration Team',
				   @toAddress = U.Email,
				   @fromAddress = OSCon.FromEmail,
				   @orgId = OU.OrganisationId
				   	
			FROM [dbo].[User] U
			JOIN [dbo].[OrganisationUser] OU
			ON OU.UserId = U.Id
			JOIN [dbo].[OrganisationSystemConfiguration] OSCon
			ON OSCon.OrganisationId = OU.OrganisationId
			WHERE U.Id = @userId
			If(@LoginNotified = 0)
				BEGIN
					BEGIN TRY
					-- TODO Insert correct value for  @requestedByUserId once that user story has been completed
						EXEC uspSendEmail @toEmailAddresses=@toAddress,
										  @emailSubject=@emailTitle,
										  @emailContent=@emailBody,
										  @organisationId=@orgId,
										  @requestedByUserId=1;	
						UPDATE [dbo].[User] 
						SET LoginNotified = 'true'
						WHERE Id = @userId;
					END TRY

					BEGIN CATCH
					END CATCH
				END
		END
		
END
GO
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP020_37.02_Fix_Create_uspSendNewUserEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


