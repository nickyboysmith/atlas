/*
	SCRIPT: Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 3
	Author: Daniel Hough
	Created: 13/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_31.04_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part4.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 4';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Payment_INSERTUPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_Payment_INSERTUPDATE;
		END
	GO

	CREATE TRIGGER TRG_Payment_INSERTUPDATE ON dbo.Payment AFTER INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Payment', 'TRG_Payment_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			BEGIN TRY
				SELECT DISTINCT
					(CASE WHEN OPT.OrganisationId IS NOT NULL THEN OPT.OrganisationId
						WHEN PM.OrganisationId IS NOT NULL THEN PM.OrganisationId
						WHEN OU.OrganisationId IS NOT NULL AND SAU.Id IS NULL THEN OU.OrganisationId
						ELSE NULL END)		AS OrganisationId
					, I.Id					AS PaymentId
				INTO #OrganisationPayment
				FROM INSERTED I
				LEFT JOIN [dbo].[OrganisationPaymentType] OPT		ON OPT.PaymentTypeId = I.PaymentTypeId	--Find Organisation By Payment Type
				LEFT JOIN [dbo].[PaymentMethod] PM					ON PM.Id = I.PaymentMethodId -- In Case No Payment Type Use Payment Method to Get Organisation
				LEFT JOIN [dbo].[OrganisationUser] OU				ON OU.UserId = I.CreatedByUserId -- If No Payment Method The Use the User Id
				LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = I.CreatedByUserId -- DO Not Allow User Organisation if a System Administration User Id is Used
				LEFT JOIN [dbo].[OrganisationPayment] OP			ON OP.PaymentId = I.Id
				WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table
				/*
					NB. There is a Chance here that a Payment Created by a System Administrator will not get assigned to an Organisation.
						There is a Trigger in the Table ClientPayment that will pick it up there.
				*/
				INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
				SELECT DISTINCT
					OP.OrganisationId		AS OrganisationId
					, OP.PaymentId			AS PaymentId
				FROM #OrganisationPayment OP
				INNER JOIN Organisation O							ON O.Id = OP.OrganisationId -- Only Valid Organisations. Will Exclude NULLS too
				LEFT JOIN [dbo].[OrganisationPayment] OP2			ON OP2.PaymentId = OP.PaymentId
				WHERE OP.OrganisationId IS NOT NULL
				AND OP2.Id IS NULL; --Only Insert if Not Already on the Table
				;
			END TRY
			BEGIN CATCH
				--SET @errMessage = '*Error Inserting Into OrganisationPayment Table';
				/*
					We Don't Need to do anything with This at the moment 
					If It is a Duplicate then it should not hapen anyway.
				*/
			END CATCH

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_ScheduledEmail_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ScheduledEmail_Insert;
		END
	GO

	CREATE TRIGGER TRG_ScheduledEmail_Insert ON dbo.ScheduledEmail AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ScheduledEmail', 'TRG_ScheduledEmail_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @id INT
				, @content VARCHAR(4000)
				, @startCheck BIT
				, @carriageReturnLineFeed VARCHAR(40) = CHAR(13) + CHAR(10)
				, @paragraph CHAR(7) = '</p><p>';

			SELECT @id = id
					, @content = Content
			FROM Inserted i;

			SELECT @startCheck = CASE WHEN LEFT(@content, 3) = '<p>' THEN 1 ELSE 0 END;

			IF(@startCheck = 'False')
			BEGIN
				SET @content = '<p>' + @content + '</p>';
				SET @content = REPLACE(@content, @carriageReturnLineFeed, @carriageReturnLineFeed + @paragraph);

				UPDATE dbo.ScheduledEmail
				SET Content = @content
				WHERE Id = @id;
			END --IF(@startCheck = 'False')

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_ScheduledEmail_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ScheduledEmail_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_ScheduledEmail_UPDATE ON dbo.ScheduledEmail FOR UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ScheduledEmail', 'TRG_ScheduledEmail_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			/* If an email has failed to Send 3 or more times then mark the email as a Send Failed */
			SELECT i.Id, Sum([SendAtempts]) AS TotalAttempts
			INTO #TooManyRetrys
			FROM inserted i
			WHERE i.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
												FROM [dbo].[ScheduledEmailState] SES
												WHERE SES.[Name] = 'Failed - Retrying')
			GROUP BY i.Id
			HAVING Sum([SendAtempts]) >= 3; /*Get All Emails which ahve failed 3 or more times.*/

			/*Set the emails to Failed Status. Stopping them from sending any more*/
			UPDATE SE
			SET [ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
											FROM [dbo].[ScheduledEmailState] SES
											WHERE SES.[Name] = 'Failed')
			FROM ScheduledEmail SE
			INNER JOIN #TooManyRetrys SE2 ON SE2.Id = SE.Id;
			/***************************************************************************************/
		
			/* Ensure that the DateUpdated is correct */
			UPDATE SE
			SET DateUpdated = GetDate()
			FROM ScheduledEmail SE
			INNER JOIN inserted i ON i.Id = SE.Id;
			/***************************************************************************************/

		
			/* Record Emails Sent Against a Service */
			INSERT INTO [dbo].[EmailServiceEmailsSent] (ScheduledEmailId, DateSent, EmailServiceId)
			SELECT i.[Id] AS ScheduledEmailId
				, GetDate() AS DateSent
				, i.[EmailProcessedEmailServiceId] AS EmailServiceId
			FROM INSERTED i
			INNER JOIN DELETED d ON D.Id = I.Id
			LEFT JOIN [dbo].[EmailServiceEmailsSent] ESES ON ESES.[ScheduledEmailId] = i.[Id]
			WHERE d.[ScheduledEmailStateId] != i.[ScheduledEmailStateId] /* Email State has Changed */
			AND i.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
												FROM [dbo].[ScheduledEmailState] SES
												WHERE SES.[Name] = 'Sent')
			AND ESES.Id IS NULL;
			/***************************************************************************************/

			/* Now Send message to Administrators about Failed Emails */
			DECLARE @OrgId int;
			DECLARE @ErrorMessage Varchar(100);
			DECLARE @ErrorMessageTitle Varchar(100);
			DECLARE @SupportUserId int;
			DECLARE @SupportUserEmail Varchar(320);
			DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
			DECLARE @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName();
			DECLARE @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress();
			DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10)
			DECLARE @Tab VARCHAR(1) = CHAR(9);
			DECLARE @sendEmail BIT = 'True';
			DECLARE @sendInternalMessage BIT = 'True';		
			DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('ERROR');
		
			DECLARE errorCursor CURSOR FOR  
			SELECT DISTINCT 
				OSE.[OrganisationId]
				, 'Multiple Send Attempts. EmailId: "' + CAST(TMR.Id AS VARCHAR) + '";'
					+ ' To: ' + SETO.[Email] + '; '
					+ ' Org: ' + O.[Name] + ';' AS ErrorMessage
				, '*Multiple Send Email Attempts on Email*' AS ErrorMessageTitle
				, SSU.[UserId] AS SupportUserId
				, U.[Email] AS SupportUserEmail
			FROM #TooManyRetrys TMR
			INNER JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[ScheduledEmailId] = TMR.Id
			INNER JOIN [dbo].[Organisation] O ON O.Id = OSE.[OrganisationId]
			INNER JOIN [dbo].[ScheduledEmailTo] SETO ON SETO.[ScheduledEmailId] = TMR.Id
			INNER JOIN [dbo].[SystemSupportUser] SSU ON SSU.[OrganisationId] = OSE.[OrganisationId]
			INNER JOIN [dbo].[User] U ON U.[Id] = SSU.[UserId]
			WHERE U.[Email] IS NOT NULL
			AND dbo.udfIsEmailAddressValid(U.[Email]) = 'True'; --Only Send to the Support User if a Valid Email Address
		
			OPEN errorCursor   
			FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;

			WHILE @@FETCH_STATUS = 0   
			BEGIN
			
				SELECT	@sendEmail = SendMessagesViaEmail, 
						@sendInternalMessage = sendmessagesviainternalmessaging 
				FROM [OrganisationSystemTaskMessaging]
				INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
				WHERE organisationId = @OrgId AND st.Name = 'EMAIL_MultipleEmailSendFailure';

				IF (@sendEmail = 'True')
				BEGIN
					EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
										, @fromName = @atlasSystemFromName
										, @fromEmailAddresses = @atlasSystemFromEmail
										, @toEmailAddresses = @SupportUserEmail
										, @emailSubject = @ErrorMessageTitle
										, @emailContent = @ErrorMessage
										, @organisationId = @OrgId
				END
			
				IF (@sendInternalMessage = 'True')
				BEGIN
					EXEC dbo.uspSendInternalMessage 
										@MessageCategoryId = @MessageCategoryId
										, @MessageTitle = @ErrorMessageTitle
										, @MessageContent = @ErrorMessage
										, @SendToUserId = @SupportUserId
										, @CreatedByUserId = @atlasSystemUserId
										;
				END

				FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;
			END   

			CLOSE errorCursor   
			DEALLOCATE errorCursor
			

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_ScriptLog_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ScriptLog_Insert;
		END
	GO

	CREATE TRIGGER TRG_ScriptLog_Insert ON dbo.ScriptLog AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ScriptLog', 'TRG_ScriptLog_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @firstBlock CHAR(3)
					, @secondBlock CHAR(5)
					, @scriptName VARCHAR(400)
					, @scriptStartCharacters CHAR(2);

			SELECT @scriptName = [Name] FROM Inserted i;
			SELECT @scriptStartCharacters = LEFT(@scriptName, 2); --Grabs first 2 characters
			SELECT @firstBlock = SUBSTRING(@scriptName, 3, 3); --Starting from the third character, grabs next 3 characters
			SELECT @secondBlock = SUBSTRING(@scriptName, 7, 5); --Starting from the 7th character, grabs next 5 characters

			UPDATE dbo.SystemControl
			SET DateOfLastDatabaseUpdate = GETDATE()
				, DatabaseVersionPart2 = DATEPART(YEAR, GETDATE())
			WHERE Id = 1; -- Should only have 1 row in this table, but just in case..

	
			IF(@scriptStartCharacters = 'SP' AND ISNUMERIC(@firstBlock) = 1 AND ISNUMERIC(@secondBlock) = 1) -- evaluating ISNUMERIC didn't like 'True' so had to use 1
			BEGIN
				UPDATE dbo.SystemControl
				SET DatabaseVersionPart3 = 	CAST(@firstBlock AS INT)
					, DatabaseVersionPart4 = CAST(@secondBlock AS FLOAT)
				WHERE Id = 1;
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_SystemFeatureItem_InsertUpdateDelete', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_SystemFeatureItem_InsertUpdateDelete;
		END
	GO

	CREATE TRIGGER TRG_SystemFeatureItem_InsertUpdateDelete ON dbo.SystemFeatureItem AFTER INSERT, UPDATE, DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'SystemFeatureItem', 'TRG_SystemFeatureItem_InsertUpdateDelete', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @firstBlock CHAR(3)
					, @secondBlock CHAR(5)
					, @scriptName VARCHAR(400)
					, @scriptStartCharacters CHAR(2);

			SELECT @scriptName = [Name] FROM Inserted i;
			SELECT @scriptStartCharacters = LEFT(@scriptName, 2); --Grabs first 2 characters
			SELECT @firstBlock = SUBSTRING(@scriptName, 3, 3); --Starting from the third character, grabs next 3 characters
			SELECT @secondBlock = SUBSTRING(@scriptName, 7, 5); --Starting from the 7th character, grabs next 5 characters

			UPDATE dbo.SystemControl
			SET DateOfLastDatabaseUpdate = GETDATE()
				, DatabaseVersionPart2 = DATEPART(YEAR, GETDATE())
			WHERE Id = 1; -- Should only have 1 row in this table, but just in case..

	
			IF(@scriptStartCharacters = 'SP' AND ISNUMERIC(@firstBlock) = 1 AND ISNUMERIC(@secondBlock) = 1) -- evaluating ISNUMERIC didn't like 'True' so had to use 1
			BEGIN
				UPDATE dbo.SystemControl
				SET DatabaseVersionPart3 = 	CAST(@firstBlock AS INT)
					, DatabaseVersionPart4 = CAST(@secondBlock AS FLOAT)
				WHERE Id = 1;
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_SystemStateSummary_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_SystemStateSummary_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_SystemStateSummary_UPDATE ON dbo.SystemStateSummary FOR UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'SystemStateSummary', 'TRG_SystemStateSummary_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO SystemStateSummaryHistory
					(
					SystemStateSummaryId
					, OrganisationId
					, Code
					, [Message]
					, SystemStateId
					, DateUpdated
					, AddedByUserId
					)
			SELECT		
						i.id
						,i.OrganisationId
						, i.Code
						, i.[Message]
						, i.SystemStateId
						, i.DateUpdated
						, i.AddedByUserId

			FROM Inserted i 
			INNER JOIN Deleted d ON i.id = d.id
			WHERE (i.OrganisationId <> d.OrganisationId 
					OR i.Code <> d.Code
					OR i.[Message] <> d.[Message]
					OR i.SystemStateId <> d.SystemStateId
					OR i.AddedByUserId <> d.AddedByUserId
					OR i.DateUpdated <> d.DateUpdated
					)
			;


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT;
		END
	GO

	CREATE TRIGGER TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT ON dbo.SystemTask FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'SystemTask', 'TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @SysUserId int;
			SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';

			INSERT INTO dbo.OrganisationSystemTaskMessaging
			(OrganisationId, SystemTaskId, SendMessagesViaEmail, SendMessagesViaInternalMessaging, UpdatedByUserId, DateUpdated)
			SELECT 
				O.Id AS OrganisationId
				, I.Id AS SystemTaskId
				, 'True' AS SendMessagesViaEmail
				, 'True' AS SendMessagesViaInternalMessaging
				, @SysUserId AS UpdatedByUserId
				, GetDate() AS DateUpdated
			FROM INSERTED I, dbo.Organisation O

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_TrainerToInsertTrainerDocument_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_TrainerToInsertTrainerDocument_INSERT;
		END
	GO

	CREATE TRIGGER TRG_TrainerToInsertTrainerDocument_INSERT ON dbo.Trainer FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Trainer', 'TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO [dbo].[TrainerDocument]
			   ([OrganisationId]
			   ,[TrainerId]
			   ,[DocumentId])
			SELECT
				atd.OrganisationId
			   ,i.Id
			   ,atd.DocumentId 
			FROM
			   inserted i
			   INNER JOIN TrainerOrganisation ton on i.Id = ton.TrainerId
			   INNER JOIN AllTrainerDocument atd on ton.OrganisationId = atd.OrganisationId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_TrainerOrganisation_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_TrainerOrganisation_Insert;
		END
	GO

	CREATE TRIGGER TRG_TrainerOrganisation_Insert ON dbo.TrainerOrganisation AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'TrainerOrganisation', 'TRG_TrainerOrganisation_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#TrainerVenue', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TrainerVenue;
			END

			DECLARE @Id INT
				  , @rowCount INT
				  , @counter INT = 1
				  , @venueId INT
				  , @trainerId INT;

			-- Inserts the appropriate Trainer and Venue Id's in to a temporary table
			-- that will be looped through later.
			SELECT tro.TrainerId
			 , tro.OrganisationId
			 , v.Id as VenueId
			INTO #TrainerVenue
			FROM TrainerOrganisation tro
			INNER JOIN dbo.Venue v ON tro.OrganisationId = v.OrganisationId
			INNER JOIN dbo.VenueAddress va ON va.VenueId = v.Id
			INNER JOIN dbo.[Location] l ON l.Id = va.LocationId
			INNER JOIN dbo.TrainerLocation tl ON tro.TrainerId = tl.TrainerId
			INNER JOIN dbo.[Location] trainerloc ON trainerloc.Id = tl.LocationId
			WHERE tro.Id = @Id;

			-- Gets the row count of the table for use in the loop later
			SELECT @rowCount = @@ROWCOUNT;

			-- Adds an Id to the temp table which will be used for the loop
			ALTER TABLE #TrainerVenue
			ADD Id INT IDENTITY(1,1) PRIMARY KEY;

			WHILE @counter <= @rowCount
			BEGIN
				SELECT @venueId = VenueId, @trainerId = TrainerId FROM #TrainerVenue WHERE Id = @counter;

				-- Checks to see if there's already an entry on TrainerVenue for the venue and trainer
				-- If there is then it skips it, if there isn't it inserts in to TrainerVenue then calls
				-- The stored procedure to calculate distance
				IF NOT EXISTS(SELECT TOP(1) TrainerId, VenueId FROM dbo.TrainerVenue WHERE TrainerId = @TrainerId AND VenueId = @VenueId)
				BEGIN
					INSERT INTO dbo.TrainerVenue(trainerId, VenueId, DateUpdated, UpdatedByUserId)
					VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId());
					EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;
				END

				SET @counter = @counter + 1;
			END


			IF OBJECT_ID('tempdb..#TrainerVenue', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TrainerVenue;
			END


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT;
		END
	GO

	CREATE TRIGGER TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT ON dbo.UserFeedback FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'UserFeedback', 'TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
			DECLARE @userId INT;
			DECLARE @OrganisationId INT;
			DECLARE @fromName VARCHAR(320);
			DECLARE @fromEmailAddresses VARCHAR(320);
			DECLARE @emailContent VARCHAR(4000);
			DECLARE @responseRequired VARCHAR(3);
			DECLARE @ccEmailAddresses VARCHAR(320);
			DECLARE @bccEmailAddresses VARCHAR(320);
			DECLARE @toEmailAddresses VARCHAR(320);
			DECLARE @toEmailName VARCHAR(320);
			DECLARE @feedbackEmail VARCHAR(320);
			DECLARE @usersEmail VARCHAR(320);
			DECLARE @usersName VARCHAR(320);
			DECLARE @usersURL VARCHAR(200);
			DECLARE @creationDate DATETIME;
			DECLARE @feedbackSubject VARCHAR(500);
			DECLARE @feedbackTitle VARCHAR(500) = 'Feedback Acknowledgement';
			DECLARE @feedbackBody VARCHAR(1000);

			/* ATLAS ADMIN SYSTEM CONTROL */
			DECLARE @atlasSystemFromName VARCHAR(320);
			DECLARE @atlasSystemFromEmail VARCHAR(320);
			DECLARE @atlasToEmailName VARCHAR(320);
			DECLARE @atlasToEmailAddress VARCHAR(320);

			/* NOT USED */
			DECLARE @asapFlag BIT = 'false'
			DECLARE	@sendAfterDateTime DATETIME = null
			DECLARE	@emailServiceId INT = null

			SELECT TOP 1 @userId = i.UserId
					, @fromName = osc.FromName
					, @fromEmailAddresses = osc.FromEmail
					, @usersName = u.Name
					, @feedbackEmail = i.Email
					, @usersEmail = u.Email
					, @feedbackTitle = i.Title
					, @feedbackBody = i.Body
					, @OrganisationId = ou.OrganisationId
					, @responseRequired = CASE WHEN i.ResponseRequired = 1 THEN 'Yes' ELSE 'No' END
					, @usersURL = i.CurrentURL
					, @creationDate = i.CreationDate
			FROM
					inserted i
					INNER JOIN [User] u ON i.UserId = u.Id
					INNER JOIN OrganisationUser ou ON i.UserId = ou.UserId
					LEFT JOIN OrganisationSystemConfiguration osc ON ou.OrganisationId = osc.OrganisationId
		
			IF (@feedbackEmail IS NULL OR @feedbackEmail = '')
				SET @toEmailAddresses = @usersEmail;	/* check usersEmail is valid ? */
			ELSE
				SET @toEmailAddresses = @feedbackEmail;

			SET @emailContent = 'This is an Automated reply.' + @NewLineChar + 'We have received your Feedback. Thank you.';

			IF (@responseRequired = 'Yes') 
				BEGIN

					SET @emailContent = @emailContent + @NewLineChar + 'We note that you have requested a follow up call or message. We will endeavour to get back to you as soon as possible.';
					SET @emailContent = @emailContent + @NewLineChar + 'Your Feedback was as follow:';
					SET @emailContent = @emailContent + @NewLineChar + 'Title: ' + @feedbackTitle + @NewLineChar + @NewLineChar + @feedbackBody;
				END

			EXEC dbo.uspSendEmail @UserId
								, @fromName
								, @fromEmailAddresses
								, @toEmailAddresses
								, @ccEmailAddresses
								, @bccEmailAddresses
								, @feedbackTitle
								, @emailContent
								, @asapFlag
								, @sendAfterDateTime
								, @emailServiceId
								, @organisationId 

			SELECT TOP 1      @atlasSystemFromName = sc.AtlasSystemFromName
							, @atlasSystemFromEmail = sc.AtlasSystemFromEmail
							, @atlasToEmailName = sc.FeedbackName
							, @atlasToEmailAddress = sc.FeedbackEmail
			FROM  systemControl sc;

			SET @feedbackSubject = 'Feedback from Atlas User - ' + @feedbackTitle
		
			SET @emailContent = 'Feedback from User: ' + @usersName;
			SET @emailContent = @emailContent + @NewLineChar + 'User''s URL: ' + @usersURL;
			SET @emailContent = @emailContent + @NewLineChar + 'User''s Email: ' + @usersEmail; 
			SET @emailContent = @emailContent + @NewLineChar + 'Respond To Email: ' + @atlasToEmailAddress; 
			SET @emailContent = @emailContent + @NewLineChar + 'Respond Required ' + @responseRequired;
			SET @emailContent = @emailContent + @NewLineChar + 'Feedback Created ' + CONVERT(VARCHAR(10), @creationDate, 103); 
			SET @emailContent = @emailContent + @NewLineChar + 'Title: ' + @feedbackTitle; 
			SET @emailContent = @emailContent + @NewLineChar + @NewLineChar + @feedbackBody; 



			EXEC dbo.uspSendEmail @UserId
								, @atlasSystemFromName
								, @atlasSystemFromEmail
								, @atlasToEmailAddress
								, @ccEmailAddresses
								, @bccEmailAddresses
								, @feedbackSubject
								, @emailContent
								, @asapFlag
								, @sendAfterDateTime
								, @emailServiceId
								, @organisationId

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_UserLogin_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_UserLogin_INSERT;
		END
	GO

	CREATE TRIGGER TRG_UserLogin_INSERT ON dbo.UserLogin AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'UserLogin', 'TRG_UserLogin_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @LoginId varchar(50);
			DECLARE @Success bit;
	
			/* This will just capture single rows. 
			Won't work if multirows are inserted. */
	
			SELECT @LoginId = i.LoginId, @Success = i.Success FROM inserted i;
			/* check for null loginid do not call */
	
			IF @LoginId IS NOT NULL EXEC dbo.usp_SetUserLogin @LoginId, @Success;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_VenueToInsertVenueRegion_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_VenueToInsertVenueRegion_INSERT;
		END
	GO

	CREATE TRIGGER TRG_VenueToInsertVenueRegion_INSERT ON dbo.Venue FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Venue', 'TRG_VenueToInsertVenueRegion_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#OrganisationRegionCount') IS NOT NULL
			BEGIN
				DROP TABLE #OrganisationRegionCount;
			END

			SELECT i.OrganisationId AS OrganisationId 
				   ,COUNT(*) AS OrgRegCount
			INTO #OrganisationRegionCount
			FROM inserted i 
			INNER JOIN OrganisationRegion orgr ON orgr.OrganisationId = i.OrganisationId
			GROUP BY i.OrganisationId;

			INSERT INTO [dbo].[VenueRegion]
			   ([VenueId]
			   ,[RegionId])
			SELECT
				i.Id
			   ,orgr.RegionId 
			FROM
			   Venue i
			   INNER JOIN OrganisationRegion orgr on i.OrganisationId = orgr.OrganisationId
			   INNER JOIN #OrganisationRegionCount orc on i.OrganisationId = orc.OrganisationId
			WHERE 
				 (orc.OrgRegCount = 1) AND 
				 NOT EXISTS 
					(SELECT *
						FROM VenueRegion vr
						WHERE (i.Id = vr.VenueId ) AND 
							(orgr.RegionId = vr.RegionId));

			IF OBJECT_ID('tempdb..#OrganisationRegionCount') IS NOT NULL
			BEGIN
				DROP TABLE #OrganisationRegionCount;
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_VenueToUpdateDistance_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_VenueToUpdateDistance_Update;
		END
	GO

	CREATE TRIGGER TRG_VenueToUpdateDistance_Update ON dbo.Venue AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Venue', 'TRG_VenueToUpdateDistance_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
				  , @venueId INT
				  , @trainerVenueCount INT
				  , @counter INT = 1;

			SELECT @venueId = i.id FROM Inserted i;
	
			-- Retrieves a count of rows which matches the trainer id. This will be used for the loop.
			SELECT @trainerVenueCount = COUNT(Id)
			FROM dbo.TrainerVenue
			WHERE VenueId = @VenueId;

			--Loops through the rows executing the stored proc for each row 
			IF (@trainerVenueCount > 0)
			BEGIN
				WHILE (@counter <= @trainerVenueCount)
				BEGIN
					SELECT TOP(1) @trainerId = TrainerId
					FROM dbo.TrainerVenue
					WHERE VenueId = @venueId;

					EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;

					SET @counter = @counter + 1;
				END
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_VenueToUpdateTrainerVenueDistance_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_VenueToUpdateTrainerVenueDistance_Update;
		END
	GO

	CREATE TRIGGER TRG_VenueToUpdateTrainerVenueDistance_Update ON dbo.Venue AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Venue', 'TRG_VenueToUpdateTrainerVenueDistance_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
				  , @venueId INT
				  , @trainerVenueCount INT
				  , @counter INT = 1;

			SELECT @venueId = i.id FROM Inserted i;
	
			-- Retrieves a count of rows which matches the trainer id. This will be used for the loop.
			SELECT @trainerVenueCount = COUNT(Id)
			FROM dbo.TrainerVenue
			WHERE VenueId = @VenueId;

			--Loops through the rows executing the stored proc for each row 
			IF (@trainerVenueCount > 0)
			BEGIN
				WHILE (@counter <= @trainerVenueCount)
				BEGIN
					SELECT TOP(1) @trainerId = TrainerId
					FROM dbo.TrainerVenue
					WHERE VenueId = @venueId;

					EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;

					SET @counter = @counter + 1;
				END
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_31.04_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part4.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO