/*
	SCRIPT: Amend uspCreateEmailCourseReminders
	Author: Dan Hough
	Created: 23/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_15.01_Amend_uspCreateEmailCourseReminders.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspCreateEmailCourseReminders -- add in venue address';

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
		DECLARE @ProcedureName VARCHAR(200) = 'uspCreateEmailCourseReminders'
				, @ErrMessage VARCHAR(4000) = ''
				, @ErrorNumber INT = NULL
				, @ErrorSeverity INT = NULL
				, @ErrorState INT = NULL
				, @ErrorProcedure VARCHAR(140) = NULL
				, @ErrorLine INT = NULL;

		BEGIN TRY
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
			DECLARE @venueAddressTag CHAR(16) = '<!VenueAddress!>';
			DECLARE @venuePostCodeTag CHAR(17) = '<!VenuePostCode!>';
			DECLARE @venueAddress VARCHAR(500);
			DECLARE @venuePostCode VARCHAR(20);

			DECLARE newClientCourseReminderCursor CURSOR FOR 
			SELECT 
				v.OrganisationId
				, v.CourseId
				, v.ClientId
				, o.[Name] 	
				, v.ClientName
				, v.CourseType
				, v.StartDate
				, v.ClientEmailAddress
				, osm.FromName
				, osm.FromEmail
				, oetm.Content
				, L.[Address]
				, L.PostCode
			FROM [dbo].[vwCourseClientWithEmailRemindersDue] v
				INNER JOIN Organisation o ON o.Id = v.OrganisationId
				INNER JOIN OrganisationSystemConfiguration osm ON osm.OrganisationId = v.OrganisationId
				INNER JOIN CourseVenue CV ON v.CourseId = CV.CourseId
				INNER JOIN VenueAddress VA ON CV.VenueId = VA.VenueId
				INNER JOIN [Location] L ON VA.LocationId = L.Id
				LEFT JOIN OrganisationEmailTemplateMessage oetm ON oetm.OrganisationId = v.OrganisationId	
															AND oetm.Code = @CourseReminderCode	;			

		
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
												, @Content
												, @venueAddress
												, @venuePostCode;

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
					SELECT @Content = REPLACE(@Content, @venueAddressTag, @venueAddress);
					SELECT @Content = REPLACE(@Content, @venuePostCodeTag, @venuePostCode);

					EXEC @ScheduledEmailId =  dbo.uspSendEmail 
									  @requestedByUserId = @RequestedByUserId
									, @fromName = @FromName
									, @fromEmailAddresses = @FromEmail
									, @toEmailAddresses = @ClientEmailAddress
									, @emailSubject = @EmailTitle
									, @emailContent = @Content
									, @asapFlag = 'True'
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

				FETCH NEXT FROM newClientCourseReminderCursor 
				INTO 
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
					, @Content
					, @venueAddress
					, @venuePostCode;
			END   


			CLOSE newClientCourseReminderCursor;  
			DEALLOCATE newClientCourseReminderCursor;

		END TRY  
		BEGIN CATCH  
		SELECT  @ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrMessage = ERROR_MESSAGE();

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH
		
	END

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP042_15.01_Amend_uspCreateEmailCourseReminders.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

