/*
	SCRIPT: Add insert trigger on CourseGroupEmailRequest
	Author: Dan Hough
	Created: 12/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_13.01_Create_InsertTriggerOnCourseGroupEmailRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the CourseGroupEmailRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseGroupEmailRequest_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseGroupEmailRequest_Insert;
		END
GO
		CREATE TRIGGER TRG_CourseGroupEmailRequest_Insert ON dbo.CourseGroupEmailRequest AFTER INSERT
AS

BEGIN
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
		  , @BCCEmailAddressesCombined VARCHAR(8000); --if @oneEmailWithHiddenAddresses is populated this could potentially be large.


	SELECT @id = i.Id
		, @courseId = i.CourseId
		, @requestedByUserId = i.RequestedByUserId
		, @sendAllClients = i.SendAllClients
		, @sendAllTrainers = i.SendAllTrainers
		, @separateEmails = i.SeparateEmails
		, @oneEmailWithHiddenAddresses = i.OneEmailWithHiddenAddresses
		, @CCEmailAddresses = i.CCEmailAddresses
		, @BCCEmailAddresses = i.BCCEmailAddresses
		, @subject = i.[Subject]
		, @startDearNamed = i.StartDearNamed
		, @startDearSirMadam = i.StartDearSirMadam
		, @startToWhomItMayConcern = i.StartToWhomItMayConcern
		, @content = i.Content
		, @sendASAP = i.SendAsap
		, @sendAfterDateTime = i.SendAfterDateTime
		, @emailsValidatedAndCreated = i.EmailsValidatedAndCreated 
		, @dateEmailsValidatedAndCreated = i.DateEmailsValidatedAndCreated
		, @requestRejected = i.RequestRejected
		, @rejectionReason = i.RejectionReason
	FROM Inserted i;

	--Get the organisationId from course table
	SELECT @organisationId = c.OrganisationId
		 , @fromEmailAddress = osc.FromEmail
		 , @fromName = osc.FromName
	FROM dbo.Course c
	INNER JOIN dbo.OrganisationSystemConfiguration osc ON c.OrganisationId = osc.OrganisationId
	WHERE c.Id = @courseId;

	CREATE TABLE #RecipientIds(RecipientId INT);

	IF(@sendAllClients = 'True')
	BEGIN
		INSERT INTO #RecipientIds(RecipientId)
		SELECT ClientId
		FROM dbo.CourseClient
		WHERE CourseId = @courseId;
	END
	ELSE IF(@sendAllTrainers = 'True')
	BEGIN
		INSERT INTO #RecipientIds(RecipientId)
		SELECT TrainerId
		FROM dbo.CourseTrainer
		WHERE CourseId = @courseId;
	END

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
			SELECT @salutation = 'Dear ' + u.[Name] + ',', @toEmailAddress = e.[Address]
			FROM dbo.Trainer t
			INNER JOIN dbo.[User] u ON t.UserId = u.Id
			INNER JOIN dbo.TrainerEmail te ON t.Id = te.TrainerId
			INNER JOIN dbo.Email e ON te.EmailId = e.Id
			WHERE t.Id = @recipientId;
		END
		ELSE IF(@startDearNamed = 'True' AND @sendAllClients = 'True')
		BEGIN
			SELECT @salutation = 'Dear ' + u.[Name] + ',', @toEmailAddress = e.[Address]
			FROM dbo.Client c
			INNER JOIN dbo.[User] u ON c.UserId = u.Id
			INNER JOIN dbo.ClientEmail ce ON c.Id = ce.ClientId
			INNER JOIN dbo.Email e ON ce.EmailId = e.Id
			WHERE c.Id = @recipientId;
		END

		SELECT @concatenatedEmailsForValidation = @toEmailAddress + ';' + @CCEmailAddresses + ';' + @BCCEmailAddresses;

		--Checks the concatenated email to make sure at least one of them is valid.
		SELECT @validEmailCheck = dbo.udfIsEmailAddressValid(@concatenatedEmailsForValidation);

		IF(@validEmailCheck = 'True')
		BEGIN
			--Set the full content by concatenating
			-- salutation and existing content.
			SELECT @concatenatedContent = @salutation 
										 + @lineBreak 
										 + @content;

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
									, 'False'; --@blindCopyToEmailAddress
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
										, 'True'; --@blindCopyToEmailAddress
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

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP030_13.01_Create_InsertTriggerOnCourseGroupEmailRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	