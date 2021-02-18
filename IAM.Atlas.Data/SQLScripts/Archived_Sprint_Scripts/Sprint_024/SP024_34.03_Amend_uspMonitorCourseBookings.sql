/*
	SCRIPT: Amend stored procedure uspMonitorCourseBookings email details of overbooked courses
	Author: Robert Newnham
	Created: 10/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_34.03_Amend_uspMonitorCourseBookings.sql';
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

		--Disable this as it does not check the number of bookings on the course against the maximum
		/*
		DECLARE bookingsCursor CURSOR FOR  
			SELECT 	
				C.Id						AS CourseId
				, U.Id						AS ToId
				, U.Email					AS ToEmail
				, 'Course Overbooked'		AS EmailTitle
				, ('The following course seems to be overbooked'
					+ @NewLine + @NewLine + 'Course Id: ' + CONVERT(varchar(10), C.Id) 
					+ @NewLine + 'Course Type: ' + ISNULL(CT.Title, 'N/A')
					+ @NewLine + 'Course Reference: ' + ISNULL(C.Reference, 'N/A')
					+ @NewLine + 'Course Dates: ' + ISNULL(dbo.ufn_GetCourseDatesAsString(C.Id), 'N/A')
					+ @NewLine + 'Course Venue: ' + ISNULL(V.Title, 'N/A')
					+ @NewLine + 'The last three clients booked on the course were: '
					+ @NewLine + 'Client Id' + @Tab + 'Date Booked' + @Tab + 'Client Name'
					+ @NewLine + ISNULL(dbo.ufn_GetCourseClientsAsString(C.Id), 'None') 
					) AS EmailContent
				, C.OrganisationId		AS OrganisationId
				FROM dbo.Course C
				LEFT JOIN dbo.CourseType CT ON CT.Id = C.CourseTypeId
				LEFT JOIN dbo.CourseVenue CV ON CV.CourseId = C.Id
				LEFT JOIN dbo.Venue V ON V.Id = CV.VenueId
				LEFT JOIN dbo.SystemControl SC ON SC.Id > 0
				LEFT JOIN dbo.OrganisationAdminUser OAU ON OAU.OrganisationId = C.OrganisationId
				LEFT JOIN dbo.[User] U ON U.Id = OAU.UserId
				LEFT JOIN CourseOverBookingNotification COBN ON COBN.CourseId = C.Id			
				WHERE dbo.udfGetFirstCourseDate(C.Id) > GETDATE()
				AND (COBN.Id IS NULL OR (COBN.DateTimeNotified IS NOT NULL AND COBN.DateTimeNotified < @ThreeDaysAgo));

			OPEN bookingsCursor
			   
		FETCH NEXT FROM bookingsCursor INTO @CourseId,
											@SupportUserId, 
											@SupportUserEmail, 
											@EmailTitle, 
											@EmailMessage, 
											@OrgId;

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
								, @fromName = @atlasSystemFromName
								, @fromEmailAddresses = @atlasSystemFromEmail
								, @toEmailAddresses = @SupportUserEmail
								, @emailSubject = @EmailTitle
								, @emailContent = @EmailMessage
								, @organisationId = @OrgId;

			INSERT INTO CourseOverBookingNotification(CourseId, DateTimeNotified)
			SELECT @CourseId AS CourseId, GetDate() AS DateTimeNotified;

			FETCH NEXT FROM bookingsCursor INTO @CourseId,
											@SupportUserId, 
											@SupportUserEmail, 
											@EmailTitle, 
											@EmailMessage, 
											@OrgId;
		END   

		CLOSE bookingsCursor   
		DEALLOCATE bookingsCursor
		--*/

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP024_34.03_Amend_uspMonitorCourseBookings.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO