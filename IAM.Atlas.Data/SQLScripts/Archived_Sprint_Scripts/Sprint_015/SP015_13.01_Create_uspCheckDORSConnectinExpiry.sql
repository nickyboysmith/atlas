/*
	SCRIPT: Create a stored procedure to send emails and messages when a user's DORS login is about to expire.
	Author: Paul Tuck
	Created: 04/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_13.01_Create_uspCheckDORSConnectionExpiry.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to send emails and messages when a user''s DORS login is about to expire.';
		
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
CREATE PROCEDURE uspCheckDORSConnectionExpiry
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
	DECLARE @messageBody varchar(400) = 'Your DORS Connection Details are due to expire shortly.' + CHAR(13) + CHAR(10) + 'Please arrange for new Details as soon as possible avoiding any possible disruption in service.'
	DECLARE @fromAddress varchar(400) = 'To Be Implimented'

	/* Find users who have signed up to receive notifications for active (not expired) DORS logins. */
	SELECT * INTO #tempNotificationUsers
		FROM
			(
			SELECT
				[user].Id UserId,
				LastNotificationSent,
				Email,
				DATEDIFF(DAY, GETDATE(), DATEADD(DAY, @passwordexpirydays, DORSConnection.PasswordLastchanged)) daysTillPasswordExpires,
				DORSConnectionId
			FROM DORSConnection
			INNER JOIN DorsConnectionNotification ON DORSConnection.Id = DorsConnectionNotification.[DORSConnectionID]
			INNER JOIN [User] ON [User].Id = [NotificationUserId]
			WHERE DATEDIFF(DAY, GETDATE(), DATEADD(DAY, @passwordexpirydays, DORSConnection.PasswordLastchanged)) > 0
			) NotificationUsersQuery
		
	SELECT @notificationUserId = min(userId) from #tempNotificationUsers

	WHILE @notificationUserId is not null
		BEGIN
			SELECT @daysTillPasswordExpires = daysTillPasswordExpires,
					@lastNotificationSent = LastNotificationSent,
					@notificationUserEmail = Email,
					@DORSConnectionId = DORSConnectionId
					FROM #tempNotificationUsers

			IF @daysTillPasswordExpires < 16
			BEGIN
				-- If a notification Email has not been sent within the last 4 days then generate a Notification Message
				IF DATEDIFF(DAY, GETDATE(), @lastNotificationSent) >= 4 OR @lastNotificationSent IS NULL
					BEGIN
						INSERT INTO [Message](Title, Content, CreatedByUserId, DateCreated, MessageCategoryId, [Disabled], AllUsers)
							OUTPUT INSERTED.Id INTO @lastInsertedMessage
						VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), 3, 0, 0)	-- MessageCategoryId of 3 is a Warning Message
						SELECT @lastInsertedMessageId = lastInsertedMessageId FROM @lastInsertedMessage
						INSERT INTO MessageRecipient (MessageId, UserId) VALUES (@lastInsertedMessageId, @notificationUserId)

						-- send an email to the user
						EXEC	[dbo].[uspSendEmail]
								@fromEmailAddress = NULL,
								@fromEmailAddresses = @fromAddress,
								@toEmailAddresses = @notificationUserEmail,
								@ccEmailAddresses = NULL,
								@bccEmailAddresses = NULL,
								@emailTitle = @MessageTitle,
								@emailContent = @MessageBody,
								@asapFlag = NULL,
								@sendAfterDateTime = NULL,
								@emailServiceId = NULL

						UPDATE DORSConnection SET [LastNotificationSent] = GETDATE() where Id = @DORSConnectionId
					END
				-- Update the DORSStateId in the DORConnection Table to "5" (Warning Level 2) if the Expiry is in less than 8 days then "6" (Warning Level 3)
				IF @daysTillPasswordExpires < 8
					BEGIN
						UPDATE DORSConnection SET DORSStateID = 6 WHERE Id = @DORSConnectionId	-- Warning level 3
					END
				ELSE
					BEGIN
						UPDATE DORSConnection SET DORSStateID = 5 WHERE Id = @DORSConnectionId	-- Warning level 2
				END
			END

			-- get the next notification user's Id
			SELECT @notificationUserId = min(UserId) FROM #tempNotificationUsers WHERE UserId > @notificationUserId
		END

		DROP TABLE #tempNotificationUsers
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_13.01_Create_uspCheckDORSConnectionExpiry.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
