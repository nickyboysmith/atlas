/*
	SCRIPT: Amend SP uspSendSMS. Give it some content
	Author: Robert Newnham
	Created: 02/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_03.03_AmendSP_uspSendSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP uspSendSMS. Give it some content';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendSMS', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendSMS;
END		
GO

	/*
		Create uspCheckUser
	*/
	CREATE PROCEDURE uspSendSMS
	(	
		@requestedByUserId int
		, @toPhoneNumber varchar(20)
		, @smsContent varchar(400)
		, @IdentifyingName VARCHAR(320)
		, @IdentifyingId INT
		, @IdType VARCHAR(100)				
		, @asapFlag bit = 'False'
		, @sendAfterDateTime DateTime = null
		, @smsServiceId int = null
		, @organisationId int = null	
	)
	AS
	BEGIN
		/*
			Parameters
			@requestedByUserId int					--Who is Requesting this SMS
			, @toPhoneNumber varchar(20)			--The Phone Number
			, @smsContent varchar(400)				--The SMS content
			, @IdentifyingName VARCHAR(320)			--Name of Person SMS is being sent to
			, @IdentifyingId INT					--ID from the Table that will FIND the Person (such as the Clinet Id)
			, @IdType VARCHAR(100)					--The Type of Id (such as "Client")
			, @asapFlag bit = false					--Send the SMS ASAP (Optional)
			, @sendAfterDateTime DateTime = null	--Send the SMA After this Date and Time (Optional). NB. Will use ASAP if True.
			, @smsServiceId int = null				--Preferred SMS Service (Optional). In most cases this should not be enetered
			, @organisationId int = null			--Organisation the SMS will be recorded under (Optional). NB if not passed the SP will get the Organisation from the User Details
		*/
		DECLARE @isSystemAdministrator BIT = 'False';
		DECLARE @errMess VARCHAR(100), @errSev INT, @errState INT;
		
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
			RETURN -1;
		END
		
		BEGIN
			/* Check if Systems Administrator */
			SET @isSystemAdministrator = 'False';
			IF (EXISTS(SELECT * FROM [dbo].[SystemAdminUser] WHERE [UserId] = @requestedByUserId))
			BEGIN
				SET @isSystemAdministrator = 'True';
			END
		END

		if (ISNULL(@organisationId,0) <= 0)
		BEGIN
			SELECT TOP 1 @organisationId=OU.OrganisationId
			FROM [dbo].[User] U
			INNER JOIN [dbo].[OrganisationUser] OU ON OU.UserId = U.Id
			LEFT JOIN [dbo].[OrganisationManagement] OM ON OM.[OrganisationId] = OU.[OrganisationId]
			WHERE U.Id = @requestedByUserId
			AND OM.Id IS NULL
			;
		END

		if (ISNULL(@organisationId,0) <= 0 AND @isSystemAdministrator = 'False')
		BEGIN
			--No Organisation for the User. Error
			SET @errMess = 'Error ** Invalid User Id: ' + CAST(@requestedByUserId AS VARCHAR) + ' - Not assigned to an Organisation**';
			SET @errSev = 1;
			SET @errState = 1;
			RAISERROR (@errMess
						, @errSev -- Severity.
						, @errState -- State.
						);
			RETURN -1;
			;
		END
		
		IF (@sendAfterDateTime IS NULL)
		BEGIN
			SET @sendAfterDateTime = GETDATE();
		END
		
		BEGIN
			DECLARE @creationDate DateTime
					, @smsStateId int
					, @scheduledSMSId int;
			SET @creationDate = GetDate();
			SELECT @smsStateId=Id FROM [dbo].[ScheduledSMSState] WHERE [Name] = 'Pending';

			BEGIN TRANSACTION;
			BEGIN TRY
				--Transaction 1
				INSERT INTO [dbo].[ScheduledSMS]
					   (
					   Content
					   , DateCreated
					   , ScheduledSMSStateId
					   , ASAP
					   , SendAfterDate
					   , OrganisationId
					   , DateScheduledSMSStateUpdated
					   , SendAttempts
					   , SMSProcessedSMSServiceId
					   )
				 VALUES
					   (
					   @smsContent
					   , @creationDate
					   , @smsStateId
					   , @asapFlag
					   , @sendAfterDateTime
					   , @organisationId
					   , @creationDate
					   , 0
					   , @smsServiceId
					   );

				SET @scheduledSMSId = SCOPE_IDENTITY();
				--Transaction 2
				INSERT INTO [dbo].[ScheduledSMSTo]
						   (
						   ScheduledSMSId
						   , PhoneNumber
						   , IdentifyingName
						   , IdentifyingId
						   , IdType
						   )
				VALUES
						   (
						   @scheduledSMSId
						   , @toPhoneNumber
						   , @IdentifyingName
						   , @IdentifyingId
						   , @IdType
						   );

				IF (@organisationId IS NOT NULL)
				BEGIN
					--Transaction 3
					INSERT INTO [dbo].[OrganisationScheduledSMS]
							   (
							   [ScheduledSMSId]
							   ,[OrganisationId]
							   )
					VALUES
							   (
							   @scheduledSMSId
							   , @organisationId
							   );
				END

				IF (@isSystemAdministrator = 'True')
				BEGIN
					--Transaction 3/4
					INSERT INTO [dbo].[SystemScheduledSMS]
							   (
							   [ScheduledSMSId]
							   )
					VALUES
							   (
							   @scheduledSMSId
							   );
				END

			END TRY
			BEGIN CATCH
				SET @errMess = ERROR_MESSAGE();
				SET @errSev = ERROR_SEVERITY();
				SET @errState = ERROR_STATE();

				IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION;
			
				RAISERROR (@errMess
							, @errSev -- Severity.
							, @errState -- State.
							);
				RETURN -1;
			END CATCH;

			IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION;
				RETURN @scheduledSMSId;
			END

		
		END

	END
	GO
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP027_03.03_AmendSP_uspSendSMS.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


