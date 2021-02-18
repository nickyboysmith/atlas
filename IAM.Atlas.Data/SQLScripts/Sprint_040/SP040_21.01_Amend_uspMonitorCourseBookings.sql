/*
	SCRIPT: Amend stored procedure uspMonitorCourseBookings email details of overbooked courses. Fix error with Fetch.
	Author: Dan Hough
	Created: 07/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_21.01_Amend_uspMonitorCourseBookings.sql';
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
		DECLARE @OrgId int
				, @EmailMessage VARCHAR(100)
				, @EmailTitle VARCHAR(100)
				, @CourseId INT
				, @SupportUserId INT
				, @SupportUserEmail VARCHAR(320)
				, @atlasSystemUserId INT = dbo.udfGetSystemUserId()
				, @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName()
				, @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress()
				, @NewLine VARCHAR(2) = CHAR(13) + CHAR(10)
				, @Tab VARCHAR(1) = CHAR(9)
				, @ThreeDaysAgo DateTime = GETDATE() - 3
				, @sendEmail BIT = 'True'
				, @sendInternalMessage BIT = 'True'
				, @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('WARNING');

		--Disable this as it does not check the number of bookings on the course against the maximum
		--/*
		DECLARE bookingsCursor CURSOR FOR 
			SELECT DISTINCT
				C.CourseId								AS CourseId
				, C.OrganisationId						AS OrganisationId
				, U.Id									AS ToId
				, U.Email								AS ToEmail
				, OSTM.SendMessagesViaEmail				AS SendMessagesViaEmail
				, OSTM.SendMessagesViaInternalMessaging AS SendMessagesViaInternalMessaging
				, 'Course Overbooked'					AS EmailTitle
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
					+ @NewLine + dbo.udfGetTopThreeCourseClientsAsString(C.CourseId) 
					) AS EmailContent
			FROM vwCourseDetail C
				INNER JOIN dbo.[OrganisationAdminUser] OAU ON OAU.OrganisationId = C.OrganisationId
				INNER JOIN dbo.[User] U ON U.Id = OAU.UserId
				INNER JOIN dbo.[OrganisationSystemTaskMessaging] OSTM ON OSTM.OrganisationId = C.OrganisationId
				INNER JOIN dbo.[SystemTask] ST ON OSTM.SystemTaskId = ST.Id
				LEFT JOIN CourseOverBookingNotification COBN ON COBN.CourseId = C.CourseId		
			WHERE C.StartDate > GETDATE()
				AND (COBN.Id IS NULL OR (COBN.DateTimeNotified IS NOT NULL AND COBN.DateTimeNotified < @ThreeDaysAgo))
				AND ISNULL(C.[MaximumVenuePlaces], 0) > 0
				AND ISNULL(C.[PlacesRemaining], 0) < 0
				AND ST.Name = 'COURSE_MonitorCourseOverBookings'
				;

		OPEN bookingsCursor;
			   
		FETCH NEXT FROM bookingsCursor INTO @CourseId,
											@OrgId,
											@SupportUserId, 
											@SupportUserEmail, 
											@sendEmail,
											@sendInternalMessage,
											@EmailTitle, 
											@EmailMessage
											;

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
												@OrgId,
												@SupportUserId, 
												@SupportUserEmail, 
												@sendEmail,
												@sendInternalMessage,
												@EmailTitle, 
												@EmailMessage
												;
		END   

		CLOSE bookingsCursor;
		DEALLOCATE bookingsCursor;

		

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP040_21.01_Amend_uspMonitorCourseBookings.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO