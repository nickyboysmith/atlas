/*
	SCRIPT: Insert trigger to DocumentMarkedForDelete table
	Author: Paul Tuck
	Created: 26/07/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP023_35.01_AmendDocumentMarkedForDeleteTableInsertTrigger';
DECLARE @ScriptComments VARCHAR(800) = 'Insert trigger to DocumentMarkedForDelete table';

EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;/*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DocumentMarkedForDelete_Insert]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_DocumentMarkedForDelete_Insert];
END
GO

CREATE TRIGGER TRG_DocumentMarkedForDelete_Insert ON DocumentMarkedForDelete
AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT id FROM inserted)
	BEGIN
		
		IF NOT EXISTS (SELECT id FROM deleted)

			DECLARE @notificationUserId INT
			DECLARE @lastNotificationSent DATETIME
			DECLARE @notificationUserEmail varchar(400)
			DECLARE @lastInsertedMessage table(lastInsertedMessageId INT)
			DECLARE @lastInsertedMessageId INT
			DECLARE @messageTitle varchar(400) = 'Documents marked for deletion.'
			DECLARE @messageBody varchar(400) = 'Documents marked for deletion.' 
												+ CHAR(13) + CHAR(10) 
												+ 'Please confirm this document should be deleted as soon as possible avoiding any possible disruption in service.'
			DECLARE @fromAddress varchar(400) = ''
			DECLARE @fromName varchar(400) = ''
			DECLARE @RequestedByUserId INT;
			DECLARE @OrganisationId INT;
			DECLARE @DocumentId INT;
			DECLARE @sendEmail BIT = 0;
			DECLARE @sendInternalMessage BIT = 0;

			SELECT @RequestedByUserId = RequestedByUserId FROM inserted
			SELECT @DocumentId = DocumentId FROM inserted
			SELECT @OrganisationId = OrganisationId FROM DocumentOwner where DocumentId = @DocumentId
			
			IF @OrganisationId IS NULL
				BEGIN
					RETURN;
				END

			SELECT	@sendEmail = SendMessagesViaEmail, 
					@sendInternalMessage = sendmessagesviainternalmessaging 
			FROM [OrganisationSystemTaskMessaging]
			INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
			WHERE organisationId = @organisationId AND st.Name = 'DOCS_NotifyDocumentMarkedForDelete'


			SELECT * INTO #tempNotificationUsers
				FROM
					(
						SELECT 
							[User].Id UserId, 
							[user].Email, 
							OAU.OrganisationId,
							OSC.FromName,
							OSC.FromEmail

						FROM organisationAdminUser OAU

						inner join [user] on userid = [user].id
						inner join organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId

						WHERE OAU.organisationId = @organisationId
					) NotificationUsersQuery
		
			SELECT @notificationUserId = min(userId) from #tempNotificationUsers

			WHILE @notificationUserId is not null
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
							VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), 3, 0, 0)	-- MessageCategoryId of 3 is a Warning Message
							
							SELECT @lastInsertedMessageId = lastInsertedMessageId FROM @lastInsertedMessage
								INSERT INTO MessageRecipient (MessageId, UserId) VALUES (@lastInsertedMessageId, @notificationUserId)

						END
					
					IF @sendEmail = 1
						BEGIN
							-- send an email to the organisation administrators
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
						END

				-- get the next notification user's Id
				SELECT @notificationUserId = min(UserId) FROM #tempNotificationUsers WHERE UserId > @notificationUserId
			END

			DROP TABLE #tempNotificationUsers
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_35.01_AmendDocumentMarkedForDeleteTableInsertTrigger';

EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO