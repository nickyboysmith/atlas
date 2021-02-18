/*
	SCRIPT: Alter uspSendClientSpecialRequirementsOutstandingNotification- use dbo.udfGetMessageCategoryId
	Author: Nick Smith
	Created: 29/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP044_10.01_Alter_uspSendClientSpecialRequirementsOutstandingNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter uspSendClientSpecialRequirementsOutstandingNotification';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendClientSpecialRequirementsOutstandingNotification', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendClientSpecialRequirementsOutstandingNotification;
END		
GO
	/*
		Create uspSendClientSpecialRequirementsOutstandingNotification
	*/

	CREATE PROCEDURE dbo.uspSendClientSpecialRequirementsOutstandingNotification (@organisationId INT
																				, @clientId INT
																				, @clientDisplayName VARCHAR(640)
																				, @specialRequirements VARCHAR(Max))
	AS
	BEGIN
				DECLARE @today varchar(40);
				DECLARE @notificationUserId INT;
				DECLARE @lastNotificationSent DATETIME;
				DECLARE @notificationUserEmail varchar(400);
				DECLARE @lastInsertedMessage table(lastInsertedMessageId INT);
				DECLARE @lastInsertedMessageId INT;
				DECLARE @messageTitle varchar(400) = 'Client Booked on Course with Special Requirement';
				DECLARE @messageBody varchar(1000);
				DECLARE @fromAddress varchar(400) = '';
				DECLARE @fromName varchar(400) = '';
				DECLARE @RequestedByUserId INT;
				DECLARE @sendEmail BIT = 0;
				DECLARE @sendInternalMessage BIT = 0;

				DECLARE @NotifyAdminOnly BIT = 0;
				DECLARE @NotifySupportUsersOnly BIT = 0;
				DECLARE @NotifyAllUsers BIT = 0;
				
				DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
				DECLARE @systemUserId INT = dbo.udfGetSystemUserId();
			
				SELECT @today = replace(convert(char(11),getdate(),113),' ',' '); --returns, for example, 01 Aug 2016

				----Concatenates First Name and Surname FROM Client table if @displayName is null
				IF (@clientDisplayName IS NULL OR LEN(@clientDisplayName) = 0)
				BEGIN 
					SELECT @clientDisplayName = LTRIM(RTRIM(C.Title + ' ' + C.FirstName + ' ' + C.Surname))
					FROM Client C
					WHERE C.Id = @clientId;
				END
										
				SELECT @messageBody =  'Hello,' 
										+ @NewLineChar 
										+ 'A Client, ' + @clientDisplayName 
										+ ',  has booked onto a Course and has a Special Requirement of ' 
										+ @specialRequirements + ' This happened on ' + @today
										+ @NewLineChar
										+ @NewLineChar
										+ 'Atlas Administration';
			
				SELECT	@sendEmail = SendMessagesViaEmail, 
						@sendInternalMessage = sendmessagesviainternalmessaging 
				FROM [OrganisationSystemTaskMessaging]
				INNER JOIN [SystemTask] ST ON SystemTaskId = ST.Id
				WHERE OrganisationId = @organisationId 
				AND ST.[Name] = 'CLIENT_MonitorClientsWithSpecialRequirements';

				SELECT	@NotifyAdminOnly = SpecialRequirementsToAdminsOnly, 
						@NotifySupportUsersOnly = SpecialRequirementsToSupportUsers,
						@NotifyAllUsers = SpecialRequirementsToAllUsers  
				FROM [OrganisationSelfConfiguration]
				WHERE OrganisationId = @organisationId;

				CREATE  TABLE #tempNotificationUsers
				(
					UserId INT NOT NULL
					, Email VARCHAR(320)
					, OrganisationId INT NOT NULL
					, FromName VARCHAR(320)
					, FromEmail VARCHAR(320)
				);

				IF @NotifyAdminOnly = 'true'
				BEGIN
					INSERT 
					INTO #tempNotificationUsers (UserId, Email, OrganisationId, FromName, FromEmail)
					SELECT [User].Id UserId, 
							[user].Email, 
							OAU.OrganisationId,
							OSC.FromName,
							OSC.FromEmail
					FROM OrganisationAdminUser OAU
					INNER JOIN [user] on userid = [user].id
					INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId
					WHERE OAU.organisationId = @organisationId
					AND [user].[Disabled] = 'false' 
				END

				ELSE IF @NotifySupportUsersOnly = 'true'
				BEGIN
					INSERT 
					INTO #tempNotificationUsers (UserId, Email, OrganisationId, FromName, FromEmail)
					SELECT [User].Id UserId, 
								[user].Email, 
								SSU.OrganisationId,
								OSC.FromName,
								OSC.FromEmail
					FROM SystemSupportUser SSU
					INNER JOIN [user] on userid = [user].id
					INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = SSU.organisationId
					WHERE SSU.organisationId = @organisationId
					AND [user].[Disabled] = 'false'
				END

				ELSE IF @NotifyAllUsers = 'true'
				BEGIN
					INSERT 
					INTO #tempNotificationUsers (UserId, Email, OrganisationId, FromName, FromEmail)
					SELECT [User].Id UserId, 
								[user].Email, 
								OU.OrganisationId,
								OSC.FromName,
								OSC.FromEmail
					FROM OrganisationUser OU
					INNER JOIN [user] on userid = [user].id
					INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = OU.organisationId
					WHERE OU.organisationId = @organisationId
					AND [user].[Disabled] = 'false'
				END

				SELECT @notificationUserId = MIN(userId) 
				FROM #tempNotificationUsers;

				WHILE @notificationUserId IS NOT NULL
				BEGIN
					SELECT  @notificationUserEmail = Email,
							@organisationId = OrganisationId,
							@fromName = FromName,
							@fromAddress = FromEmail
							FROM #tempNotificationUsers
							WHERE UserId = @notificationUserId

					IF @sendInternalMessage = 1
					BEGIN
						INSERT INTO [Message](Title, Content, CreatedByUserId, DateCreated, MessageCategoryId, [Disabled], AllUsers)
							OUTPUT INSERTED.Id INTO @lastInsertedMessage
						VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), dbo.udfGetMessageCategoryId('WARNING'), 0, 0)
							
						SELECT @lastInsertedMessageId = lastInsertedMessageId 
						FROM @lastInsertedMessage;

						INSERT INTO MessageRecipient (MessageId, UserId) 
						VALUES (@lastInsertedMessageId, @notificationUserId);
					END --IF @sendInternalMessage = 1
					
					IF @sendEmail = 1
					BEGIN
						-- send an email to the organisation administrators
						EXEC	[dbo].[uspSendEmail]
									@requestedByUserId = @systemUserId
									, @fromName = @fromName
									, @fromEmailAddresses  = @fromAddress
									, @toEmailAddresses = @notificationUserEmail
									, @ccEmailAddresses = null
									, @bccEmailAddresses = null
									, @emailSubject = @MessageTitle
									, @emailContent = @MessageBody
									, @asapFlag = NULL
									, @sendAfterDateTime = NULL
									, @emailServiceId = NULL
									, @organisationId = @organisationId
					END --IF @sendEmail = 1

					-- get the next notification user's Id
					SELECT @notificationUserId = MIN(UserId) 
					FROM #tempNotificationUsers 
					WHERE UserId > @notificationUserId;
				END --WHILE @notificationUserId IS NOT NULL

				DROP TABLE #tempNotificationUsers

				-- Update ClientSpecialRequirement and ClientOtherRequirement
				-- Set OrganisationNotified = True 

				UPDATE ClientSpecialRequirement
				SET OrganisationNotified = 'True'
				WHERE ClientId = @clientId

				UPDATE ClientOtherRequirement
				SET OrganisationNotified = 'True'
				WHERE ClientId = @clientId
				
			END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP044_10.01_Alter_uspSendClientSpecialRequirementsOutstandingNotification.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO