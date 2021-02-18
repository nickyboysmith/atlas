/*
	SCRIPT: Add insert trigger to the ClientSpecialRequirement table
	Author: Dan Hough
	Created: 01/08/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP024_09.01_AddInsertTriggerToClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the ClientSpecialRequirement table';

EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;/*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.TRG_ClientSpecialRequirement_INSERT', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_ClientSpecialRequirement_INSERT];
END
GO

CREATE TRIGGER TRG_ClientSpecialRequirement_INSERT ON ClientSpecialRequirement
AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT id FROM inserted)
	BEGIN
		
		IF NOT EXISTS (SELECT id FROM deleted)
			
			DECLARE @clientId INT;
			DECLARE @clientDisplayName varchar(640);
			DECLARE @specialRequirementName varchar(100);
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
			DECLARE @OrganisationId INT;
			DECLARE @sendEmail BIT = 0;
			DECLARE @sendInternalMessage BIT = 0;
			
			SELECT TOP 1 @RequestedByUserId = AddByUserId FROM inserted i;  --Correct Id?
			SELECT @today = replace(convert(char(11),getdate(),113),' ',' '); --returns, for example, 01 Aug 2016
			SELECT TOP 1 @clientId = ClientId from inserted;
			SELECT @specialRequirementName = sr.Name FROM SpecialRequirement sr INNER JOIN inserted i ON i.SpecialRequirementId = sr.Id WHERE sr.id = i.SpecialRequirementId;
			SELECT @OrganisationId = co.OrganisationId  FROM clientspecialrequirement csc INNER JOIN clientorganisation co ON csc.ClientId = co.ClientId WHERE csc.ClientId = @clientId;
			SELECT @clientDisplayName = c.DisplayName FROM Client c INNER JOIN clientspecialrequirement csc ON csc.ClientId = c.Id WHERE csc.ClientId = @clientId;

			--Concatenates First Name and Surname from Client table if @displayName is null
			IF @clientDisplayName IS NULL 
				BEGIN 
					SELECT @clientDisplayName = c.FirstName + ' ' + c.Surname 
					FROM Client c 
					INNER JOIN inserted i on i.ClientId = c.Id
					WHERE c.Id = @clientId;
				END
										
			SELECT @messageBody =  'Hello,' 
									+ CHAR(13) + CHAR(10) 
									+ 'A Client, ' + @clientDisplayName + ',  has booked onto a Course and has a Special Requirement of ' + @specialRequirementName + ' This happened on ' + @today
									+ CHAR(13) + CHAR(10) 
									+ CHAR(13) + CHAR(10) 
									+ 'Atlas Administration';
			
			IF @OrganisationId IS NULL
				BEGIN
					RETURN;
				END

			SELECT	@sendEmail = SendMessagesViaEmail, 
					@sendInternalMessage = sendmessagesviainternalmessaging 
			FROM [OrganisationSystemTaskMessaging]
			INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
			WHERE organisationId = @organisationId AND st.Name = 'CLIENT_MonitorClientsWithSpecialRequirements';


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

						INNER JOIN [user] on userid = [user].id
						INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId

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
DECLARE @ScriptName VARCHAR(100) = 'SP024_09.01_AddInsertTriggerToClientSpecialRequirement.sql';

EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO
