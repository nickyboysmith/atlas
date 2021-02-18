/*
	SCRIPT: Amend trigger to the CourseGroupEmailRequest table: log trigger run times into the TriggerLog
	Author: Paul Tuck
	Created: 07/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_05.01_Amend_InsertTriggerOnCourseGroupEmailRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseGroupEmailRequest_InsertUpdate]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseGroupEmailRequest_InsertUpdate];
	END
GO
	/*******************************************************************************************************************/
	CREATE TRIGGER [dbo].[TRG_CourseGroupEmailRequest_InsertUpdate] ON [dbo].[CourseGroupEmailRequest] AFTER INSERT, UPDATE
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN	
			-- log the trigger in the trigger log
			EXEC uspLogTriggerRunning 'CourseGroupEmailRequest', 'TRG_CourseGroupEmailRequest_InsertUpdate', @insertedRows, @deletedRows;
			
			DECLARE @id INT
				  , @courseId INT
				  , @requestedByUserId INT
				  , @sendAllClients BIT
				  , @sendAllTrainers BIT
				  , @separateEmails BIT
				  , @oneEmailWithHiddenAddresses BIT
				  , @CCEmailAddresses VARCHAR(1000)
				  , @BCCEmailAddresses VARCHAR(1000) 
				  , @subject VARCHAR(1000)
				  , @startDearNamed BIT
				  , @startDearSirMadam BIT
				  , @startToWhomItMayConcern BIT
				  , @content VARCHAR(4000)
				  , @concatenatedContent VARCHAR(4000)
				  , @sendASAP BIT
				  , @sendAfterDateTime DATETIME
				  , @emailsValidatedAndCreated BIT
				  , @dateEmailsValidatedAndCreated DATETIME
				  , @requestRejected BIT
				  , @rejectionReason VARCHAR(200)
				  , @lineBreak VARCHAR(20) = CHAR(13) + CHAR(10)
				  , @recipientCount INT
				  , @cnt INT = 1
				  , @organisationId INT
				  , @fromEmailAddress VARCHAR(320)
				  , @fromName VARCHAR(320)
				  , @toEmailAddress VARCHAR(320)
				  , @salutation VARCHAR(100)
				  , @recipientId INT
				  , @validEmailCheck BIT
				  , @concatenatedEmailsForValidation VARCHAR(8000)
				  , @BCCEmailAddressesCombined VARCHAR(8000) --if @oneEmailWithHiddenAddresses is populated this could potentially be large.
				  , @readyToSend BIT = 'False'
				  , @pendingEmailAttachmentId INT
				  , @firstAttachmentId INT
				  ;


			SELECT @id = I.Id
				, @courseId = I.CourseId
				, @requestedByUserId = I.RequestedByUserId
				, @sendAllClients = I.SendAllClients
				, @sendAllTrainers = I.SendAllTrainers
				, @separateEmails = I.SeparateEmails
				, @oneEmailWithHiddenAddresses = I.OneEmailWithHiddenAddresses
				, @CCEmailAddresses = I.CCEmailAddresses
				, @BCCEmailAddresses = I.BCCEmailAddresses
				, @subject = I.[Subject]
				, @startDearNamed = I.StartDearNamed
				, @startDearSirMadam = I.StartDearSirMadam
				, @startToWhomItMayConcern = I.StartToWhomItMayConcern
				, @content = I.Content
				, @sendASAP = I.SendAsap
				, @sendAfterDateTime = I.SendAfterDateTime
				, @emailsValidatedAndCreated = I.EmailsValidatedAndCreated 
				, @dateEmailsValidatedAndCreated = I.DateEmailsValidatedAndCreated
				, @requestRejected = I.RequestRejected
				, @rejectionReason = I.RejectionReason
				, @organisationId = C.OrganisationId
				, @fromEmailAddress = OSC.FromEmail
				, @fromName = OSC.FromName
				, @readyToSend = I.ReadyToSend
			FROM INSERTED I
			INNER JOIN dbo.Course C ON C.Id = I.CourseId
			INNER JOIN dbo.OrganisationSystemConfiguration OSC ON C.OrganisationId = OSC.OrganisationId
			WHERE I.ReadyToSend = 'True'
			AND ISNULL(EmailsValidatedAndCreated, 'False') = 'True';

			IF (@courseId IS NOT NULL AND @readyToSend = 'True')
			BEGIN
			
				CREATE TABLE #RecipientIds(RecipientId INT);

				IF(@sendAllClients = 'True')
				BEGIN
					INSERT INTO #RecipientIds(RecipientId)
					SELECT ClientId
					FROM dbo.CourseClient
					WHERE CourseId = @courseId;
				END --IF(@sendAllClients = 'True')
				ELSE IF(@sendAllTrainers = 'True')
				BEGIN
					INSERT INTO #RecipientIds(RecipientId)
					SELECT TrainerId
					FROM dbo.CourseTrainer
					WHERE CourseId = @courseId;
				END --ELSE IF(@sendAllTrainers = 'True')

				--Provide an id row for use in below loop
				ALTER TABLE #RecipientIds
				ADD TempId INT IDENTITY(1,1);

				-- grab count of recipients for use in below loop
				SELECT @recipientCount = COUNT(TempId) FROM #RecipientIds;

				--Update Salutation
				IF (@startDearSirMadam = 'True')
				BEGIN
					SET @salutation = 'Dear Sir or Madam, ';
				END
				ELSE IF (@startToWhomItMayConcern = 'True')
				BEGIN
					SET @salutation = 'To whom it may concern, ';
				END

				--Loop through the table and either send emails or add
				--the email address to BCCEmailAddresses if @oneEmailWithHiddenAddresses
				--is true, then send email on last loop.
				WHILE @cnt <= @recipientCount
				BEGIN
					SELECT @recipientId = RecipientId 
					FROM #RecipientIds 
					WHERE TempId = @cnt;

					IF(@startDearNamed = 'True' AND @sendAllTrainers = 'True')
					BEGIN
						SELECT @salutation = 'Dear ' + T.DisplayName + ',', @toEmailAddress = e.[Address]
						FROM dbo.Trainer T
						INNER JOIN dbo.TrainerEmail TE	ON T.Id = TE.TrainerId
						INNER JOIN dbo.Email E			ON TE.EmailId = E.Id
						WHERE T.Id = @recipientId;
					END
					ELSE IF(@startDearNamed = 'True' AND @sendAllClients = 'True')
					BEGIN
						SELECT @salutation = 'Dear ' + C.DisplayName + ',', @toEmailAddress = e.[Address]
						FROM dbo.Client C
						INNER JOIN dbo.ClientEmail CE	ON C.Id = CE.ClientId
						INNER JOIN dbo.Email E			ON CE.EmailId = e.Id
						WHERE C.Id = @recipientId;
					END

					SELECT @concatenatedEmailsForValidation = @toEmailAddress + ';' + @CCEmailAddresses + ';' + @BCCEmailAddresses;

					--Checks the concatenated email to make sure at least one of them is valid.
					SELECT @validEmailCheck = dbo.udfIsEmailAddressValid(@concatenatedEmailsForValidation);

					IF(@validEmailCheck = 'True')
					BEGIN
						--Set the full content by concatenating
						-- salutation and existing contenT.
						SELECT @concatenatedContent = @salutation 
													 + @lineBreak 
													 + @content;

						--Allow for Email Attachements
						SET @firstAttachmentId = NULL;
						SET @pendingEmailAttachmentId = NULL;
						SELECT TOP 1 @firstAttachmentId=Id
						FROM CourseGroupEmailRequestAttachment CGERA
						WHERE CGERA.CourseGroupEmailRequestId = @id;

						IF (@firstAttachmentId IS NOT NULL)
						BEGIN
							--First Attachment
							INSERT INTO [dbo].[PendingEmailAttachment] (SameEmailAs_PendingEmailAttachmentId, DocumentId, DateAdded)
							SELECT 
								NULL				AS SameEmailAs_PendingEmailAttachmentId
								, CGERA.DocumentId	AS DocumentId
								, GETDATE()			AS DateAdded
							FROM CourseGroupEmailRequestAttachment CGERA
							WHERE CGERA.Id = @firstAttachmentId
							AND CGERA.CourseGroupEmailRequestId = @id;

							SET @pendingEmailAttachmentId = SCOPE_IDENTITY();

							--Allow for Multiple Attachments
							INSERT INTO [dbo].[PendingEmailAttachment] (SameEmailAs_PendingEmailAttachmentId, DocumentId, DateAdded)
							SELECT 
								@pendingEmailAttachmentId	AS SameEmailAs_PendingEmailAttachmentId --Linking Attachments Together
								, CGERA.DocumentId			AS DocumentId
								, GETDATE()					AS DateAdded
							FROM CourseGroupEmailRequestAttachment CGERA
							WHERE CGERA.Id != @firstAttachmentId --Not the First One. All the Others
							AND CGERA.CourseGroupEmailRequestId = @id;
						END

						IF(@separateEmails = 'True')
						BEGIN
							EXEC dbo.uspSendEmail @requestedByUserId --@requestedByUserId
												, @fromName --@fromName
												, @fromEmailAddress --@fromEmailAddresses
												, @toEmailAddress --@toEmailAddresses
												, @CCEmailAddresses --@ccEmailAddresses
												, @BCCEmailAddresses--@bccEmailAddresses
												, @subject --@emailSubject
												, @concatenatedContent --@emailContent
												, @sendASAP --@asapFlag
												, @sendAfterDateTime --@sendAfterDateTime
												, NULL--@emailServiceId
												, @organisationId --@organisationId
												, 'False' --@blindCopyToEmailAddress
												, @pendingEmailAttachmentId
												;
						END --IF(@separateEmails = 'True')

						ELSE IF(@oneEmailWithHiddenAddresses = 'True')
						BEGIN
							--Add the CCEmailAddress to BCCEmailAddresses
							SELECT @BCCEmailAddressesCombined = @BCCEmailAddresses + ';' + @CCEmailAddresses;

							--If it's the last loop, send the email.
							IF(@cnt = @recipientCount)
							BEGIN
								EXEC dbo.uspSendEmail @requestedByUserId --@requestedByUserId
													, @fromName --@fromName
													, @fromEmailAddress --@fromEmailAddresses
													, @toEmailAddress --@toEmailAddresses
													, NULL --@ccEmailAddresses
													, @BCCEmailAddresses--@bccEmailAddresses
													, @subject --@emailSubject
													, @concatenatedContent --@emailContent
													, @sendASAP --@asapFlag
													, @sendAfterDateTime --@sendAfterDateTime
													, NULL--@emailServiceId
													, @organisationId --@organisationId
													, 'True' --@blindCopyToEmailAddress
													, @pendingEmailAttachmentId
													;
							END --IF(@cnt = @recipientCount)

						END -- IF(@oneEmailWithHiddenAddresses = 'True')
			
						--Clear out the  variables used in loop.
						SET @salutation = NULL;
						SET @concatenatedEmailsForValidation = NULL;
						SET @validEmailCheck = NULL;
						SET @BCCEmailAddressesCombined = NULL;
						SET @concatenatedContent = NULL;

						SET @cnt = @cnt +1;
					END--EmailVerification
				END--while

				IF(@validEmailCheck = 'False')
				BEGIN
					UPDATE dbo.CourseGroupEmailRequest
					SET RequestRejected = 'True', RejectionReason = 'All destination email addresses were not in the correct format'
					WHERE Id = @id;
				END
				ELSE
				BEGIN
					UPDATE dbo.CourseGroupEmailRequest
					SET EmailsValidatedAndCreated = 'True', DateEmailsValidatedAndCreated = GETDATE()
					WHERE Id = @id;
				END

				DROP TABLE #RecipientIds;

			END --IF (@courseId IS NOT NULL AND I.ReadyToSend = 'True')
		END --END PROCESS

	END
	GO
	/*******************************************************************************************************************/

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_05.01_Amend_InsertTriggerOnCourseGroupEmailRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO