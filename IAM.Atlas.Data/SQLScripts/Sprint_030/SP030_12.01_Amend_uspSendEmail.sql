/*
	SCRIPT: Amend the SendEmail Stored Procedure To Incorporate BCC emails only with no To address
	Author: Nick Smith
	Created: 06/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_12.01_Amend_uspSendEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend the SendEmail Stored Procedure To Incorporate BCC emails only with no To address';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendEmail', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendEmail;
END		
GO

/*
	Create uspSendEmail
*/
CREATE PROCEDURE [dbo].[uspSendEmail](	
								@requestedByUserId int
								, @fromName varchar(400) = null
								, @fromEmailAddresses varchar(400)
								, @toEmailAddresses varchar(400)
								, @ccEmailAddresses varchar(400) = null
								, @bccEmailAddresses varchar(400) = null
								, @emailSubject varchar(320)
								, @emailContent varchar(4000)
								, @asapFlag bit = false
								, @sendAfterDateTime DateTime = null
								, @emailServiceId int = null
								, @organisationId int = null
								, @blindCopyToEmailAddress BIT = false
								)
AS
BEGIN

	DECLARE @isSystemAdministrator bit;
	DECLARE @errMess VARCHAR(100), @errSev int, @errState int;;

	IF NOT EXISTS(SELECT * FROM [dbo].[User] WHERE [Id] = @requestedByUserId)
	BEGIN
		/* Invalid User */
		SET @errMess = 'Error ** Invalid User Id: ' + CAST(@requestedByUserId AS VARCHAR) + ' **';
		SET @errSev = 1;
		SET @errState = 1;
		RAISERROR (@errMess
					, @errSev -- Severity.
					, @errState -- State.
					);
		RETURN;
	END

	BEGIN
		/* Check if Systems Administrator */
		SET @isSystemAdministrator = 'False';
		IF (EXISTS(SELECT * FROM [dbo].[SystemAdminUser] WHERE [UserId] = @requestedByUserId))
		BEGIN
			SET @isSystemAdministrator = 'True';
		END
	END

	IF (@sendAfterDateTime IS NULL)
	BEGIN
		SET @sendAfterDateTime = GETDATE();
	END

	IF (@organisationId IS NULL)
	BEGIN
		/* Find Organisation Id if Not Passed. Ensure that it is the Managing Organisation Id. */
		SELECT TOP 1 @organisationId = OU.[OrganisationId]
		FROM [dbo].[OrganisationUser] OU
		LEFT JOIN [dbo].[OrganisationManagement] OM ON OM.[OrganisationId] = OU.[OrganisationId]
		WHERE OU.[UserId] = @requestedByUserId AND OM.Id IS NULL;

		/* NB. The Organisation Id may still be null if the email is being sent by a Systems Administrator. */
	END
	
	BEGIN
		DECLARE @creationDate DateTime
				, @emailStateId int
				, @scheduledEmailId int;
		SET @creationDate = GetDate();
		SELECT @emailStateId=Id FROM [dbo].[ScheduledEmailState] WHERE [Name] = 'Pending';
		
		IF(@blindCopyToEmailAddress = 'True')
		BEGIN
			SET @bccEmailAddresses = @bccEmailAddresses + ';' + @toEmailAddresses;
		END

		BEGIN TRANSACTION;
		BEGIN TRY
			
			--Transaction 1
			INSERT INTO [dbo].[ScheduledEmail]
				   (
				   [FromName]
				   , [FromEmail]
				   , [Content]
				   , [DateCreated]
				   , [Disabled]
				   , [ASAP]
				   , [SendAfter]
				   , [ScheduledEmailStateId]
				   , [DateScheduledEmailStateUpdated]
				   , [SendAtempts]
				   , [Subject]
				   )
			 VALUES
				   (
				   @fromName
				   , @fromEmailAddresses
				   , @emailContent
				   , @creationDate
				   , 'False'
				   , @asapFlag
				   , @sendAfterDateTime
				   , @emailStateId
				   , @creationDate
				   , 0
				   , @emailSubject
				   );

			SET @scheduledEmailId = @@IDENTITY;

			IF(@blindCopyToEmailAddress = 'False') --updated
			BEGIN
				--Transaction 2 if blindCopyToEmailAddress is false
				INSERT INTO [dbo].[ScheduledEmailTo]
						   (
						   [ScheduledEmailId]
						   ,[Email]
						   ,[CC]
						   ,[BCC]
						   )
				VALUES
						   (
						   @scheduledEmailId
						   , @toEmailAddresses
						   , 'False'
						   , 'False'
						   );
			END

			IF (LEN(ISNULL(@ccEmailAddresses,'')) > 0)
			BEGIN
				--Transaction 2
				INSERT INTO [dbo].[ScheduledEmailTo]
						   (
						   [ScheduledEmailId]
						   ,[Email]
						   ,[CC]
						   ,[BCC]
						   )
				VALUES
						   (
						   @scheduledEmailId
						   , @ccEmailAddresses
						   , 'True'
						   , 'False' 
						   );
			END

			IF (LEN(ISNULL(@bccEmailAddresses,'')) > 0)
			BEGIN
				--Transaction 3
				INSERT INTO [dbo].[ScheduledEmailTo]
						   (
						   [ScheduledEmailId]
						   ,[Email]
						   ,[CC]
						   ,[BCC]
						   )
				VALUES
						   (
						   @scheduledEmailId
						   , @bccEmailAddresses
						   , 'False'
						   , 'True' 
						   )
			END
			
			IF (@organisationId IS NOT NULL)
			BEGIN
				--Transaction 4
				INSERT INTO [dbo].[OrganisationScheduledEmail]
						   (
						   [ScheduledEmailId]
						   ,[OrganisationId]
						   )
				VALUES
						   (
						   @scheduledEmailId
						   , @organisationId
						   );
			END

			IF (@isSystemAdministrator = 'True')
			BEGIN
				--Transaction 4
				INSERT INTO [dbo].[SystemScheduledEmail]
						   (
						   [ScheduledEmailId]
						   )
				VALUES
						   (
						   @scheduledEmailId
						   );
			END

		END TRY
		BEGIN CATCH
			--SELECT 
			--	ERROR_NUMBER() AS ErrorNumber
			--	,ERROR_SEVERITY() AS ErrorSeverity
			--	,ERROR_STATE() AS ErrorState
			--	,ERROR_PROCEDURE() AS ErrorProcedure
			--	,ERROR_LINE() AS ErrorLine
			--	,ERROR_MESSAGE() AS ErrorMessage;
			SET @errMess = ERROR_MESSAGE();
			SET @errSev = ERROR_SEVERITY();
			SET @errState = ERROR_STATE();

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			
			RAISERROR (@errMess
						, @errSev -- Severity.
						, @errState -- State.
						);
			RETURN;
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION;
			RETURN @scheduledEmailId;
		END

		
	END

END


GO


DECLARE @ScriptName VARCHAR(100) = 'SP030_12.01_Amend_uspSendEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
