/*
	SCRIPT: Amend uspCheckDORSConnectionExpiry
	Author: Robert Newnham
	Created: 05/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_18.03_AmendSP_uspCheckDORSConnectionExpiry.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspCheckDORSConnectionExpiry';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO


	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspCheckDORSConnectionExpiry', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspCheckDORSConnectionExpiry;
	END		
	GO
	
	/*
		Create uspCheckDORSConnectionExpiry
	*/
	CREATE PROCEDURE [dbo].[uspCheckDORSConnectionExpiry]
	AS
	BEGIN
	
		DECLARE @notificationUserId INT
		DECLARE @passwordexpirydays INT
		SELECT @passwordexpirydays = [PasswordExpiryDays] FROM DORSControl
		DECLARE @daysTillPasswordExpires INT
		DECLARE @lastNotificationSent DATETIME
		DECLARE @notificationUserEmail varchar(400)
		DECLARE @DORSConnectionId INT
		DECLARE @lastInsertedMessage table(lastInsertedMessageId INT)
		DECLARE @lastInsertedMessageId INT
		DECLARE @messageTitle varchar(400) = 'Your DORS Connection Details are due to expire shortly.'
		DECLARE @messageBody varchar(400) = 'Your DORS Connection Details are due to expire shortly.' 
											+ CHAR(13) + CHAR(10) 
											+ 'Please arrange for new Details as soon as possible avoiding any possible disruption in service.'
		DECLARE @fromAddress varchar(400) = ''
		DECLARE @fromName varchar(400) = ''
		DECLARE @organisationId INT

		/* Find users who have signed up to receive notifications for active (not expired) DORS logins. */
		SELECT * INTO #tempNotificationUsers
			FROM
				(
				SELECT
					DISTINCT
					DC.[OrganisationId],
					U.Id UserId,
					DC.LastNotificationSent,
					U.Email,
					DATEDIFF(DAY, GETDATE(), DATEADD(DAY, @passwordexpirydays, DC.PasswordLastchanged)) daysTillPasswordExpires,
					DCN.DORSConnectionId,
					OSC.[FromName],
					OSC.[FromEmail]
				FROM DORSConnection DC
				INNER JOIN DorsConnectionNotification DCN ON DC.Id = DCN.[DORSConnectionID]
				INNER JOIN [User] U ON U.Id = DCN.[NotificationUserId]
				INNER JOIN [dbo].[OrganisationSystemConfiguration] OSC ON OSC.[OrganisationId] = DC.[OrganisationId]
				WHERE DATEDIFF(DAY, GETDATE(), DATEADD(DAY, @passwordexpirydays, DC.PasswordLastchanged)) > 0
				) NotificationUsersQuery
		
		SELECT @notificationUserId = min(userId) from #tempNotificationUsers

		WHILE @notificationUserId is not null
			BEGIN
				SELECT @daysTillPasswordExpires = daysTillPasswordExpires,
						@lastNotificationSent = LastNotificationSent,
						@notificationUserEmail = Email,
						@DORSConnectionId = DORSConnectionId,
						@organisationId = OrganisationId,
						@fromName = FromName,
						@fromAddress = FromEmail
						FROM #tempNotificationUsers

				IF @daysTillPasswordExpires < 16
				BEGIN
					-- If a notification Email has not been sent within the last 4 days then generate a Notification Message
					IF DATEDIFF(DAY, GETDATE(), @lastNotificationSent) >= 4 OR @lastNotificationSent IS NULL
						BEGIN
							INSERT INTO [Message](Title, Content, CreatedByUserId, DateCreated, MessageCategoryId, [Disabled], AllUsers)
								OUTPUT INSERTED.Id INTO @lastInsertedMessage
							VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), dbo.udfGetMessageCategoryId('WARNING'), 'False', 'False')	-- Warning Message
							SELECT @lastInsertedMessageId = lastInsertedMessageId FROM @lastInsertedMessage
							INSERT INTO MessageRecipient (MessageId, UserId) VALUES (@lastInsertedMessageId, @notificationUserId)

							-- send an email to the user
							EXEC	[dbo].[uspSendEmail]
										@requestedByUserId = @notificationUserId /* TODO: This bit needs to change to a General System User Id */
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

							UPDATE DORSConnection SET [LastNotificationSent] = GETDATE() where Id = @DORSConnectionId
						END
					-- Update the DORSStateId in the DORConnection Table to "5" (Warning Level 2) if the Expiry is in less than 8 days then "6" (Warning Level 3)
					DECLARE @warningMessageId INT = (SELECT TOP 1 Id FROM DORSState DS WHERE DS.[Name] = 'Warning');
					DECLARE @warning2MessageId INT = (SELECT TOP 1 Id FROM DORSState DS WHERE DS.[Name] = 'Warning2');
					IF @daysTillPasswordExpires < 8
						BEGIN
							UPDATE DORSConnection SET DORSStateID = @warning2MessageId WHERE Id = @DORSConnectionId	-- Warning level 3
						END
					ELSE
						BEGIN
							UPDATE DORSConnection SET DORSStateID = @warningMessageId WHERE Id = @DORSConnectionId	-- Warning level 2
					END
				END

				-- get the next notification user's Id
				SELECT @notificationUserId = min(UserId) FROM #tempNotificationUsers WHERE UserId > @notificationUserId
			END

			DROP TABLE #tempNotificationUsers
	END


	GO


	
DECLARE @ScriptName VARCHAR(100) = 'SP040_18.03_AmendSP_uspCheckDORSConnectionExpiry.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO