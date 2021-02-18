/*
	SCRIPT: Create a stored procedure to email details of overbooked courses
	Author: Daniel Murray
	Created: 21/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_26.01_Amend_uspMonitorCourseBookings.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to email details of overbooked courses';
		
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
		DECLARE @EmailMessage Varchar(100);
		DECLARE @EmailTitle Varchar(100);
		DECLARE @SupportUserId int;
		DECLARE @SupportUserEmail Varchar(320);
		DECLARE @atlasSystemUserId int;
		DECLARE @atlasSystemFromName VARCHAR(320);
		DECLARE @atlasSystemFromEmail VARCHAR(320);

		DECLARE bookingsCursor CURSOR FOR  
			SELECT 	
			SC.AtlasSystemUserId	AS RequestedByUserID,
			SC.AtlasSystemFromName	AS FromName,
			SC.AtlasSystemFromEmail AS FromAddress, 
			U.Id					AS ToId,
			U.Email					AS ToEmail,
			'Course Overbooked'		AS EmailTitle,
			'The following course seems to be overbooked' + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10) +
			'Course Id: ' + CONVERT(varchar(10), C.Id)  + CHAR(13) + CHAR(10) +
			'Course Type: ' + ISNULL(CT.Title, 'N/A')  + CHAR(13) + CHAR(10) +
			'Course Reference: ' + ISNULL(C.Reference, 'N/A')  + CHAR(13) + CHAR(10) +
			'Course Dates: ' + 	ISNULL(dbo.ufn_GetCourseDatesAsString(C.Id), 'N/A') + CHAR(13) + CHAR(10) +
			'Course Venue: ' + ISNULL(V.Title, 'N/A') + CHAR(13) + CHAR(10) +
			'The last three clients booked on the course were: '+ CHAR(13) + CHAR(10) + 
			'Client Id' + CHAR(9) + 'Date Booked' + CHAR(9) + 'Client Name'	+ CHAR(13) + CHAR(10) 
			 + ISNULL(dbo.ufn_GetCourseClientsAsString(C.Id), 'None')
									AS EmailContent,
			C.OrganisationId		AS OrganisationId	
			
			FROM dbo.Course C
			LEFT JOIN dbo.CourseType CT ON CT.Id = C.CourseTypeId
			LEFT JOIN dbo.CourseDate CD ON CD.Id = 
											(SELECT TOP 1 CD1.Id
											FROM dbo.CourseDate CD1
											WHERE CD1.CourseId = C.Id 
												  AND CD1.DateStart IS NOT NULL
											ORDER BY CD1.DateStart DESC)
			LEFT JOIN dbo.CourseVenue CV ON CV.CourseId = C.Id
			LEFT JOIN dbo.Venue V ON V.Id = CV.VenueId
			LEFT JOIN dbo.SystemControl SC ON SC.Id > 0
			LEFT JOIN dbo.OrganisationAdminUser OAU ON OAU.OrganisationId = C.OrganisationId
			JOIN dbo.[User] U ON U.Id = OAU.UserId
			
			WHERE CD.DateStart > GETDATE()

			OPEN bookingsCursor
			   
		FETCH NEXT FROM bookingsCursor INTO @atlasSystemUserId, 
											@atlasSystemFromName, 
											@atlasSystemFromEmail, 
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
								, @organisationId = @OrgId

			FETCH NEXT FROM bookingsCursor INTO @atlasSystemUserId, 
											@atlasSystemFromName, 
											@atlasSystemFromEmail, 
											@SupportUserId, 
											@SupportUserEmail, 
											@EmailTitle, 
											@EmailMessage, 
											@OrgId;
		END   

		CLOSE bookingsCursor   
		DEALLOCATE bookingsCursor


	END
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_26.01_Amend_uspMonitorCourseBookings.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO