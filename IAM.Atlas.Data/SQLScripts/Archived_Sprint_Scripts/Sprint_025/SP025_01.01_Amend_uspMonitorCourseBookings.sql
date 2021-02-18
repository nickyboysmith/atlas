/*
	SCRIPT: Amend stored procedure uspMonitorCourseBookings email details of overbooked courses
	Author: Robert Newnham
	Created: 18/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_01.01_Amend_uspMonitorCourseBookings.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend stored procedure to email details of overbooked courses';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspMonitorCourseBookings', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspMonitorCourseBookings;
	END		
	GO

	/*
		Create uspUpdateDashboardMeter_DocumentSummary
	*/

	CREATE PROCEDURE dbo.uspMonitorCourseBookings
	AS
	BEGIN

		/*Now Send message to Administrators*/
		DECLARE @OrgId int;
		DECLARE @EmailMessage VARCHAR(100);
		DECLARE @EmailTitle VARCHAR(100);
		DECLARE @CourseId INT;
		DECLARE @SupportUserId INT;
		DECLARE @SupportUserEmail VARCHAR(320);
		DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
		DECLARE @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName();
		DECLARE @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress();
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @Tab VARCHAR(1) = CHAR(9);
		DECLARE @ThreeDaysAgo DateTime = GETDATE() - 3;
		DECLARE @sendEmail BIT = 'True';
		DECLARE @sendInternalMessage BIT = 'True';		
		DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('WARNING');

		--Disable this as it does not check the number of bookings on the course against the maximum
		--/*
		DECLARE bookingsCursor CURSOR FOR  
			SELECT 	
				C.CourseId					AS CourseId
				, U.Id						AS ToId
				, U.Email					AS ToEmail
				, 'Course Overbooked'		AS EmailTitle
				, ('The following course seems to be overbooked'
					+ @NewLine + @NewLine + 'Course Id: ' + CONVERT(varchar(10), C.CourseId) 
					+ @NewLine + 'Course Type: ' + ISNULL(C.CourseType, 'N/A')
					+ @NewLine + 'Course Reference: ' + ISNULL(C.CourseReference, 'N/A')
					+ @NewLine + 'Course Dates: ' + (CASE WHEN C.StartDate IS NULL THEN 'N/A'
														ELSE CONVERT(nvarchar(MAX), C.StartDate, 100) END)
												+ ' TO ' + (CASE WHEN C.EndDate IS NULL THEN 'N/A'
														ELSE CONVERT(nvarchar(MAX), C.EndDate, 100) END)
					+ @NewLine + 'Course Venue: ' + ISNULL(C.VenueName, 'N/A')
					+ @NewLine + 'Maximum Places: ' + ISNULL(CAST(C.[MaximumVenuePlaces] AS VARCHAR), 'N/A')
									+ '; Reserved: ' + ISNULL(CAST(C.[ReservedVenuePlaces] AS VARCHAR), 'N/A') 
									+ '; Places Remaining: ' +ISNULL( CAST(C.[PlacesRemaining] AS VARCHAR), 'N/A')
					+ @NewLine + 'The last three clients booked on the course were: '
					+ @NewLine + 'Client Id' + @Tab + 'Date Booked' + @Tab + 'Client Name'
					+ @NewLine + ISNULL(dbo.ufn_GetCourseClientsAsString(C.CourseId), 'None') 
					) AS EmailContent
				, C.OrganisationId		AS OrganisationId
				FROM vwCourseDetail C
				LEFT JOIN dbo.OrganisationAdminUser OAU ON OAU.OrganisationId = C.OrganisationId
				LEFT JOIN dbo.[User] U ON U.Id = OAU.UserId
				LEFT JOIN CourseOverBookingNotification COBN ON COBN.CourseId = C.CourseId			
				WHERE C.StartDate > GETDATE()
				AND (COBN.Id IS NULL OR (COBN.DateTimeNotified IS NOT NULL AND COBN.DateTimeNotified < @ThreeDaysAgo))
				AND ISNULL(C.[MaximumVenuePlaces], 0) > 0
				AND [PlacesRemaining] < 0;
				
		SELECT	@sendEmail = SendMessagesViaEmail, 
				@sendInternalMessage = sendmessagesviainternalmessaging 
		FROM [OrganisationSystemTaskMessaging]
		INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
		WHERE organisationId = @OrgId AND st.Name = 'COURSE_MonitorCourseOverBookings';

		OPEN bookingsCursor;
			   
		FETCH NEXT FROM bookingsCursor INTO @CourseId,
											@SupportUserId, 
											@SupportUserEmail, 
											@EmailTitle, 
											@EmailMessage, 
											@OrgId;

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			IF (@sendEmail = 'True')
			BEGIN
				EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
									, @fromName = @atlasSystemFromName
									, @fromEmailAddresses = @atlasSystemFromEmail
									, @toEmailAddresses = @SupportUserEmail
									, @emailSubject = @EmailTitle
									, @emailContent = @EmailMessage
									, @organisationId = @OrgId;
			END
			
			IF (@sendInternalMessage = 'True')
			BEGIN
				EXEC dbo.uspSendInternalMessage 
									@MessageCategoryId = @MessageCategoryId
									, @MessageTitle = @EmailTitle
									, @MessageContent = @EmailMessage
									, @SendToUserId = @SupportUserId
									, @CreatedByUserId = @atlasSystemUserId
									;
			END

			/* Save the Course Id in the Table "CourseOverBookingNotification" so that we do not constantly warn abou the same course */
			INSERT INTO CourseOverBookingNotification(CourseId, DateTimeNotified)
			SELECT @CourseId AS CourseId, GetDate() AS DateTimeNotified;

			FETCH NEXT FROM bookingsCursor INTO @CourseId,
											@SupportUserId, 
											@SupportUserEmail, 
											@EmailTitle, 
											@EmailMessage, 
											@OrgId;
		END   

		CLOSE bookingsCursor;
		DEALLOCATE bookingsCursor;
		--*/

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP025_01.01_Amend_uspMonitorCourseBookings.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
