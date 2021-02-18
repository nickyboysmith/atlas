/*
	SCRIPT: Amend insert trigger to the UserFeedback table to send an email to the User and Atlas Administration
	Author: Nick Smith
	Created: 24/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_11.01_AmendInsertTriggerToUserFeedbackToSendEmailToUserAndAtlasAdministration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the UserFeedback table to send an email to the User and Atlas Administration';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT];
		END
GO
		CREATE TRIGGER TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT ON UserFeedback FOR INSERT
AS		
		
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

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_11.01_AmendInsertTriggerToUserFeedbackToSendEmailToUserAndAtlasAdministration.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO