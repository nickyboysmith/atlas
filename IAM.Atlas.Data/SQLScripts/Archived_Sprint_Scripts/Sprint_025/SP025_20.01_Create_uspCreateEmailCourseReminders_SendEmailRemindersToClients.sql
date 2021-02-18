/*
	SCRIPT: uspCreateEmailCourseReminders - Sends email reminders to Clients
	Author: Nick Smith
	Created: 06/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_20.01_Create_uspCreateEmailCourseReminders_SendEmailRemindersToClients.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create_uspCreateEmailCourseReminders Send Email Reminders To Clients';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateEmailCourseReminders', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateEmailCourseReminders;
END		

GO
	/*
		Create uspCreateEmailCourseReminders
	*/
	CREATE PROCEDURE uspCreateEmailCourseReminders
	AS
	BEGIN
		/*
			For every row returned by vwCourseClientWithEmailRemindersDue that has a OrganisationEmailTemplateMessage.

			- call uspSendEmail.
			- update CourseClient Setting EmailReminderSent to 'True'
			- Insert row into CourseClientEmailReminder.

			ELSE - Set ErrorMessage, see user story ?
		*/
   
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @RequestedByUserId INT = [dbo].[udfGetSystemUserId]();
		
		DECLARE @OrganisationId INT;
		DECLARE @CourseId INT;
		DECLARE @ClientId INT;
		DECLARE @ScheduledEmailId INT;
		DECLARE @OrganisationName VARCHAR(320);
		DECLARE @ClientName VARCHAR(640);
		DECLARE @CourseType VARCHAR(200);
		DECLARE @CourseStartDate DATETIME;
		DECLARE @ClientEmailAddress VARCHAR(320);
		DECLARE @FromName VARCHAR(320);
		DECLARE @FromEmail VARCHAR(320);

		DECLARE @EmailTitle VARCHAR(15) = 'Course Reminder Email';
		DECLARE @CourseReminderCode VARCHAR(20) = 'CourseReminder'
		DECLARE @OrganisationErrorMessage VARCHAR(570);
		DECLARE @ErrorMessage VARCHAR(250) = 'Course Reminder Email Template is missing for Organisation: ';

		DECLARE @Content VARCHAR(1000);
		DECLARE @ClientNameTag VARCHAR(15) = '<!Client Name!>';
		DECLARE @CourseTypeTag VARCHAR(15) = '<!Course Type!>';
		DECLARE @CourseDateTag VARCHAR(15) = '<!Course Date!>';

		DECLARE newClientCourseReminderCursor CURSOR FOR 
		SELECT 
			v.OrganisationId
			, v.CourseId
			, v.ClientId
			, o.Name 	
			, v.ClientName
			, v.CourseType
			, v.StartDate
			, v.ClientEmailAddress
			, osm.FromName
			, osm.FromEmail
			, oetm.Content
		FROM [dbo].[vwCourseClientWithEmailRemindersDue] v
			INNER JOIN Organisation o ON o.Id = v.OrganisationId
			INNER JOIN OrganisationSystemConfiguration osm ON osm.OrganisationId = v.OrganisationId
			LEFT JOIN OrganisationEmailTemplateMessage oetm ON oetm.OrganisationId = v.OrganisationId	
														AND oetm.Code = @CourseReminderCode					

		
		OPEN newClientCourseReminderCursor;			   
		FETCH NEXT FROM newClientCourseReminderCursor INTO 
											  @OrganisationId 
											, @CourseId
											, @ClientId
											, @OrganisationName 
											, @ClientName
											, @CourseType
											, @CourseStartDate
											, @ClientEmailAddress
											, @FromName
											, @FromEmail
											, @Content;

		WHILE @@FETCH_STATUS = 0   
		BEGIN		
			
			IF (@Content IS NULL)
			BEGIN
				-- Do something with the Error
				SET @OrganisationErrorMessage = @ErrorMessage + @OrganisationName;
			END
			ELSE
			BEGIN

				SELECT @Content = REPLACE(@Content, @ClientNameTag, @ClientName);
				SELECT @Content = REPLACE(@Content, @CourseTypeTag, @CourseType);
				SELECT @Content = REPLACE(@Content, @CourseDateTag, @CourseStartDate);

				EXEC @ScheduledEmailId =  dbo.uspSendEmail 
							      @requestedByUserId = @RequestedByUserId
								, @fromName = @FromName
								, @fromEmailAddresses = @FromEmail
								, @toEmailAddresses = @ClientEmailAddress
								, @emailSubject = @EmailTitle
								, @emailContent = @Content
								, @organisationId = @OrganisationId;

				UPDATE [dbo].[CourseClient]
				SET 
					UpdatedByUserId = @RequestedByUserId
					, EmailReminderSent = 'true'
				WHERE CourseId = @CourseId
					  AND ClientId = @ClientId

				INSERT INTO [dbo].[CourseClientEmailReminder]
					(ClientId
					,CourseId
					,DateSent
					,SentByUserId
					,ScheduledEmailId)
				VALUES
					(@ClientId
					,@CourseId
					,GETDATE()
					,@RequestedByUserId
					,@ScheduledEmailId)
			END

			FETCH NEXT FROM newClientCourseReminderCursor INTO 
											  @OrganisationId 
											, @CourseId
											, @ClientId
											, @OrganisationName 
											, @ClientName
											, @CourseType
											, @CourseStartDate
											, @ClientEmailAddress
											, @FromName
											, @FromEmail
											, @Content;
		END   


		CLOSE newClientCourseReminderCursor;  
		DEALLOCATE newClientCourseReminderCursor;
		
	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP025_20.01_Create_uspCreateEmailCourseReminders_SendEmailRemindersToClients.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

