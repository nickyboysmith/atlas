/*
	SCRIPT: uspCreateSMSCourseReminders - Sends SMS reminders to Clients
	Author: Nick Smith
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_28.01_Create_uspCreateSMSCourseReminders_SendSMSRemindersToClients.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create_uspCreateSMSCourseReminders Send SMS Reminders To Clients';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateSMSCourseReminders', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateSMSCourseReminders;
END		

GO
	/*
		Create uspCreateSMSCourseReminders
	*/
	CREATE PROCEDURE uspCreateSMSCourseReminders
	AS
	BEGIN
		/*
			For every row returned by vwCourseClientWithSMSRemindersDue that has a OrganisationSMSTemplateMessage.

			- call uspSendSMS.
			- update CourseClient Setting SMSReminderSent to 'True'
			- Insert row into CourseClientSMSReminder.

			ELSE - Set ErrorMessage, see user story ?
		*/
   
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @RequestedByUserId INT = [dbo].[udfGetSystemUserId]();
		
		DECLARE @OrganisationId INT;
		DECLARE @CourseId INT;
		DECLARE @ClientId INT;
		DECLARE @ScheduledSMSId INT;
		DECLARE @OrganisationName VARCHAR(320);
		DECLARE @ClientName VARCHAR(640);
		DECLARE @CourseType VARCHAR(200);
		DECLARE @CourseStartDate DATETIME;
		DECLARE @ClientPhoneNumber VARCHAR(40);
		DECLARE @FromName VARCHAR(320);
		DECLARE @FromEmail VARCHAR(320);

		DECLARE @SMSTitle VARCHAR(15) = 'Course Reminder SMS';
		DECLARE @CourseReminderCode VARCHAR(20) = 'CourseReminder'
		DECLARE @ErrorMessage VARCHAR(570);
		DECLARE @ClientErrorMessage VARCHAR(290);

		DECLARE @TemplateErrorMessage VARCHAR(250) = 'Course Reminder SMS Template is missing for Organisation: ';
		DECLARE @ClientPhoneNumberErrorMessage VARCHAR(250) = 'No Phone Number for Client: ';

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
			, v.ClientPhoneNumber
			, osm.FromName
			, osm.FromEmail
			, oetm.Content
		FROM [dbo].[vwCourseClientWithSMSRemindersDue] v
			INNER JOIN Organisation o ON o.Id = v.OrganisationId
			INNER JOIN OrganisationSystemConfiguration osm ON osm.OrganisationId = v.OrganisationId
			LEFT JOIN OrganisationSMSTemplateMessage oetm ON oetm.OrganisationId = v.OrganisationId	
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
											, @ClientPhoneNumber
											, @FromName
											, @FromEmail
											, @Content;

		WHILE @@FETCH_STATUS = 0   
		BEGIN		
			
			IF (@Content IS NULL) OR (@ClientPhoneNumber IS NULL)
			BEGIN

				
				-- Do something with the Error
				IF (@Content IS NULL)
				SET @ErrorMessage = @TemplateErrorMessage + @OrganisationName;

				IF (@ClientPhoneNumber IS NULL)
				SET @ClientErrorMessage = @ClientPhoneNumberErrorMessage + @ClientId;

			END
			ELSE
			BEGIN

				SELECT @Content = REPLACE(@Content, @ClientNameTag, @ClientName);
				SELECT @Content = REPLACE(@Content, @CourseTypeTag, @CourseType);
				SELECT @Content = REPLACE(@Content, @CourseDateTag, @CourseStartDate);

				EXEC @ScheduledSMSId =  dbo.uspSendSMS;
							 --     @requestedByUserId = @RequestedByUserId
								--, @fromName = @FromName
								--, @fromEmailAddresses = @FromEmail
								--, @toEmailAddresses = @ClientEmailAddress
								--, @emailSubject = @SMSTitle
								--, @emailContent = @Content
								--, @organisationId = @OrganisationId;

				UPDATE [dbo].[CourseClient]
				SET 
					UpdatedByUserId = @RequestedByUserId
					, SMSReminderSent = 'true'
				WHERE CourseId = @CourseId
					  AND ClientId = @ClientId

				INSERT INTO [dbo].[CourseClientSMSReminder]
					(ClientId
					,CourseId
					,DateSent
					,SentByUserId
					,ScheduledSMSId)
				VALUES
					(@ClientId
					,@CourseId
					,GETDATE()
					,@RequestedByUserId
					,@ScheduledSMSId)
			END

			FETCH NEXT FROM newClientCourseReminderCursor INTO 
											  @OrganisationId 
											, @CourseId
											, @ClientId
											, @OrganisationName 
											, @ClientName
											, @CourseType
											, @CourseStartDate
											, @ClientPhoneNumber
											, @FromName
											, @FromEmail
											, @Content;
		END   


		CLOSE newClientCourseReminderCursor;  
		DEALLOCATE newClientCourseReminderCursor;
		
	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP025_28.01_Create_uspCreateSMSCourseReminders_SendSMSRemindersToClients.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

