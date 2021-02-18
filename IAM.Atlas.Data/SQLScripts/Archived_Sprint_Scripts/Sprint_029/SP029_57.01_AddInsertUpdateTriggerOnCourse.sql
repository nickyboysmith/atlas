/*
	SCRIPT: Add insert, update trigger on the Course table
	Author: Dan Hough
	Created: 30/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_57.01_AddInsertUpdateTriggerOnCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert, update trigger on the Course table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseVenueEmail_InsertUpdate]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseVenueEmail_InsertUpdate;
		END
GO
		CREATE TRIGGER dbo.TRG_CourseVenueEmail_InsertUpdate ON dbo.Course AFTER INSERT, UPDATE
AS

BEGIN
	DECLARE @organisationId INT
			, @AllowAutoEmailCourseVenuesOnCreationToBeSent BIT
			, @available BIT
			, @courseId INT
			, @venueId INT
			, @courseVenueEmailCheck INT
			, @courseVenueEmailCheckName CHAR(26) = 'Venue Availability Request' --also used to look up the reason id
			, @emailContent VARCHAR(1000)
			, @emailSubject VARCHAR(100)
			, @templateMessageCode CHAR(16) = 'CourseVenueAvail'
			, @venueName VARCHAR(250)
			, @courseTypeName VARCHAR(200)
			, @courseStartDate DATETIME
			, @courseEndDate DATETIME
			, @organisationDisplayName VARCHAR(320)
			, @toEmailAddress VARCHAR(320)
			, @replyEmailAddress VARCHAR(320)
			, @backupFromEmailName VARCHAR(320)
			, @backupFromEmailAddress VARCHAR(320)
			, @requestedByUserId INT
			, @isEmailValid	BIT
			, @emailSendAfterDate DATETIME
			, @scheduledEmailId INT --??
			, @reasonId INT
			, @venueNameTag CHAR(14) = '<!Venue Name!>'
			, @courseTypeNameTag CHAR(20) = '<!Course Type Name!>'
			, @courseStartDateTag CHAR(21) = '<!Course Start Date!>'
			, @courseEndDateTag CHAR(19) = '<!Course End Date!>'
			, @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
			, @replyEmailAddressTag CHAR(23) = '<!Reply Email Address!>';

	SELECT @organisationId = i.OrganisationId
			, @available = i.Available
			, @courseId = i.Id
			, @venueId = cv.VenueId
			, @venueName = v.Title --also should be used as @fromName in uspSendMail if the email is valid. If not, use backup.
			, @courseTypeName = ct.Title
			, @organisationDisplayName = od.[Name]
			, @replyEmailAddress = osc.VenueReplyEmailAddress --also should be used as @fromEmailAddress in uspSendMail if the email is valid. If not, use backup.
			, @toEmailAddress = e.[Address] --Venue email address
			, @backupFromEmailAddress = osystemc.FromEmail --this will only be used if @replyEmailAddress is invalid.
			, @backupFromEmailName = osystemc.[FromName] --this will only be used if @replyEmailAddress is invalid.
			, @allowAutoEmailCourseVenuesOnCreationToBeSent = osc.AllowAutoEmailCourseVenuesOnCreationToBeSent
			, @requestedByUserId = dbo.udfGetSystemUserId()
	FROM Inserted I
	INNER JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id
	INNER JOIN dbo.OrganisationDisplay od ON i.OrganisationId = od.OrganisationId
	INNER JOIN dbo.CourseVenue cv ON i.id = cv.CourseId
	INNER JOIN dbo.Venue v ON cv.VenueId = v.Id
	INNER JOIN dbo.VenueEmail ve ON v.id = ve.VenueId
	INNER JOIN dbo.Email e ON ve.EmailId = e.Id
	INNER JOIN dbo.OrganisationSelfConfiguration osc ON i.OrganisationId = osc.OrganisationId 
	INNER JOIN dbo.OrganisationSystemConfiguration osystemc ON i.OrganisationId = osystemc.OrganisationId;

	IF(@allowAutoEmailCourseVenuesOnCreationToBeSent = 'True')
	BEGIN
		IF(@available = 'True')
		BEGIN
			--checks to see if an email already exists
			SELECT @courseVenueEmailCheck = COUNT(cve.Id)
			FROM dbo.CourseVenueEmail cve
			INNER JOIN dbo.CourseVenueEmailReason cver ON cve.CourseVenueEmailReasonId = cve.Id
			WHERE (cve.CourseId = @courseId) 
					AND (cve.VenueId = @venueId) 
					AND (cver.[Name] = @courseVenueEmailCheckName);
			
			--If email doesn't exist it proceeds
			IF(@courseVenueEmailCheck IS NULL OR @courseVenueEmailCheck = 0)
			BEGIN
				SELECT @emailContent = Content, @emailSubject = [Subject]
				FROM dbo.OrganisationEmailTemplateMessage
				WHERE OrganisationId = @organisationId AND Code = @templateMessageCode;

				SELECT @courseStartDate = MIN(DateStart) --course might run on multiple days
				FROM dbo.CourseDate
				WHERE CourseId = @courseId;

				SELECT @courseEndDate = MAX(DateEnd) --course might run on multiple days
				FROM dbo.CourseDate
				WHERE CourseId = @courseId;

				--Checks to see if the email formatting is valid.
				SELECT @isEmailValid = CASE WHEN
											ISNULL(@replyEmailAddress, '') <> '' 
												AND @replyEmailAddress LIKE '%_@%_.__%' 
											THEN 
												'True' 
											ELSE 
												'False' 
											END;
				
				--If the email isn't valid, updates @replyEmailAddress and @venueName
				--with the backup options						
				IF(@isEmailValid = 'False')
				BEGIN
					SET @replyEmailAddress = @backupFromEmailAddress;
					SET @venueName = @backupFromEmailName;
				END 

				--Replaces the tags in the email content with data grabbed above.
				SET @emailContent = REPLACE(@emailContent, @venueNameTag, @venueName);
				SET @emailContent = REPLACE(@emailContent, @courseTypeNameTag, @courseTypeName);
				SET @emailContent = REPLACE(@emailContent, @courseStartDateTag, CAST(@courseStartDate AS VARCHAR));
				SET @emailContent = REPLACE(@emailContent, @courseEndDateTag, CAST(@courseEndDate AS VARCHAR));
				SET @emailcontent = REPLACE(@emailContent, @organisationDisplayNameTag, @organisationDisplayName);
				SET @emailContent = REPLACE(@emailContent, @replyEmailAddressTag, @replyEmailAddress);

				--doesn't allow getdate to be sent directly as a param to uspSendEmail
				SET @emailSendAfterDate = GETDATE();

				--getting email reason id
				SELECT @reasonId = Id
				FROM dbo.CourseVenueEmailReason
				WHERE [Name] = @courseVenueEmailCheckName;

				EXEC @scheduledEmailId = uspSendEmail @requestedByUserId
													, @venueName --FromName
													, @replyEmailAddress --FromEmailAddress
													, @toEmailAddress
													, NULL --ccEmailAddresses
													, NULL --bccEmailAddresses
													, @emailSubject
													, @emailContent 
													, 'True' --@asapFlag
													, @emailSendAfterDate --@sendAfterDateTime
													, NULL
													, @organisationId;
				
				--adds row in to CourseVenueEmail
				INSERT INTO dbo.CourseVenueEmail(CourseId
												, VenueId
												, DateCreated
												, ScheduledEmailId
												, CourseVenueEmailReasonId)
										VALUES  (@courseId
												, @venueId
												, GETDATE()
												, @scheduledEmailId
												, @reasonId)

			END --@courseVenueEmailCheck IS NULL
		END --@available = 'True'
	END --@allowAutoEmailCourseVenuesOnCreationToBeSent = 'True'			
END --Create trigger
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_57.01_AddInsertUpdateTriggerOnCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	