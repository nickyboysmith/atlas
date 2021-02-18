/*
	SCRIPT: Amend Insert trigger on ClientSpecialRequirement
	Author: Robert Newnham
	Created: 16/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_03.01_AmendInsertTriggerOnClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on ClientSpecialRequirement';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientSpecialRequirement_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientSpecialRequirement_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientSpecialRequirement_INSERT] ON [dbo].[ClientSpecialRequirement] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientSpecialRequirement', 'TRG_ClientSpecialRequirement_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			BEGIN
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
				DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
				DECLARE @systemUserId INT = dbo.udfGetSystemUserId();
			
				SELECT TOP 1 @RequestedByUserId = AddByUserId 
				FROM INSERTED I;  --Correct Id?

				SELECT @today = replace(convert(char(11),getdate(),113),' ',' '); --returns, for example, 01 Aug 2016

				SELECT TOP 1 @clientId = ClientId FROM inserted;

				SELECT @OrganisationId = co.OrganisationId  
				FROM ClientSpecialRequirement CSC 
				INNER JOIN ClientOrganisation co ON CSC.ClientId = co.ClientId 
				WHERE CSC.ClientId = @clientId;
			
				IF @OrganisationId IS NOT NULL
				BEGIN			
					SELECT @specialRequirementName = SR.[Name]
					FROM INSERTED I 
					INNER JOIN SpecialRequirement SR ON SR.Id = I.SpecialRequirementId
					WHERE SR.id = I.SpecialRequirementId;

					SELECT @clientDisplayName = C.DisplayName 
					FROM ClientSpecialRequirement CSC
					INNER JOIN Client C ON C.Id = CSC.ClientId
					WHERE CSC.ClientId = @clientId;

					--Concatenates First Name and Surname FROM Client table if @displayName is null
					IF @clientDisplayName IS NULL 
					BEGIN 
						SELECT @clientDisplayName = LTRIM(RTRIM(C.Title + ' ' + C.FirstName + ' ' + C.Surname))
						FROM INSERTED I
						INNER JOIN Client C ON I.ClientId = C.Id
						WHERE C.Id = @clientId;
					END
										
					SELECT @messageBody =  'Hello,' 
											+ @NewLineChar 
											+ 'A Client, ' + @clientDisplayName 
											+ ',  has booked onto a Course and has a Special Requirement of ' 
											+ @specialRequirementName + ' This happened on ' + @today
											+ @NewLineChar
											+ @NewLineChar
											+ 'Atlas Administration';
			
					SELECT	@sendEmail = SendMessagesViaEmail, 
							@sendInternalMessage = sendmessagesviainternalmessaging 
					FROM [OrganisationSystemTaskMessaging]
					INNER JOIN [SystemTask] ST ON SystemTaskId = ST.Id
					WHERE OrganisationId = @organisationId 
					AND ST.[Name] = 'CLIENT_MonitorClientsWithSpecialRequirements';

					SELECT * 
					INTO #tempNotificationUsers
					FROM
						(SELECT [User].Id UserId, 
								[user].Email, 
								OAU.OrganisationId,
								OSC.FromName,
								OSC.FromEmail
						FROM organisationAdminUser OAU
						INNER JOIN [user] on userid = [user].id
						INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId
						WHERE OAU.organisationId = @organisationId
						) NotificationUsersQuery
						;
		
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
							VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), 3, 0, 0)	-- MessageCategoryId of 3 is a Warning Message
							
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
				END --IF @OrganisationId IS NOT NULL
			END
			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_03.01_AmendInsertTriggerOnClientSpecialRequirement.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO