/*
	SCRIPT: Alter Stored procedure uspCreateAndSendTrainerBookingConfirmation
	Author: Dan Hough
	Created: 28/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_19.01_AlterSP_uspCreateAndSendTrainerBookingConfirmation';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspCreateAndSendTrainerBookingConfirmation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateAndSendTrainerBookingConfirmation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspCreateAndSendTrainerBookingConfirmation];
END		
GO
	/*
		Create [uspCreateAndSendTrainerBookingConfirmation]
	*/
	
	CREATE PROCEDURE [dbo].[uspCreateAndSendTrainerBookingConfirmation](@courseId INT, @trainerId INT)
	AS
	BEGIN

		DECLARE @trainerDisplayNameTag CHAR(22) = '<!TrainerDisplayName!>'
				, @trainerDisplayName VARCHAR(640)
				, @courseTypeTag CHAR(14) = '<!CourseType!>'
				, @courseType VARCHAR(200)
				, @courseReferenceTag CHAR(19) = '<!CourseReference!>'
				, @courseReference VARCHAR(100)
				, @courseVenueTitleTag CHAR(20) = '<!CourseVenueTitle!>'
				, @courseVenueTitle VARCHAR(200)
				, @courseVenueAddressTag CHAR(22) = '<!CourseVenueAddress!>'
				, @courseVenueAddress VARCHAR(500)
				, @courseStartDateTag CHAR(19) = '<!CourseStartDate!>'
				, @courseStartDate DATETIME
				, @courseEndDateTag CHAR(17) = '<!CourseEndDate!>'
				, @courseEndDate DATETIME
				, @courseSessionsTag CHAR(18) = '<!CourseSessions!>' --??
				, @courseSessions VARCHAR(20)
				, @contentEmail VARCHAR(4000)
				, @subjectEmail VARCHAR(100)
				, @fallbackEmailSubject CHAR(14) = 'Course Booking'
				, @atlasSystemUserId INT = dbo.udfGetSystemUserId()
				, @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName()
				, @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress()
				, @trainerEmailAddress VARCHAR(320)
				, @orgId INT
				, @systemTrappedFeatureName CHAR(42) = 'uspCreateAndSendTrainerBookingConfirmation'
				, @systemTrappedMessage VARCHAR(8000)
				, @templateCode CHAR(15) = 'TrainerBookConf'
				, @emailASAPFlag BIT = 'True'
				, @emailSendAfterDateTime DATETIME = GETDATE()
				, @trainerNotificationBCCEmailAddress VARCHAR(320); 

		SELECT DISTINCT @trainerDisplayName = ISNULL(t.DisplayName, '')
						, @trainerEmailAddress = E.[Address]
						, @courseType = '"' + ISNULL(VWCD.CourseType, '') + '"'
						, @courseReference = ISNULL(VWCD.CourseReference, '')
						, @courseVenueTitle = ISNULL(VWCD.VenueName, '')
						, @courseVenueAddress = ISNULL(L.[Address], '')
						, @courseStartDate = VWCD.StartDate
						, @courseEndDate = VWCD.EndDate
						, @contentEmail = OETM.Content
						, @subjectEmail = OETM.[Subject]
						, @orgId = VWCD.OrganisationId
						, @courseId = VWCD.CourseId
						, @trainerId = T.Id
						, @courseSessions = ISNULL(CS.SessionTitle, '')
						, @trainerNotificationBCCEmailAddress = OSC.TrainerNotificationBCCEmailAddress
			FROM dbo.Trainer T
			INNER JOIN dbo.TrainerEmail TE ON T.Id = TE.TrainerId
			INNER JOIN dbo.Email E ON TE.EmailId = E.Id
			INNER JOIN dbo.vwCourseDetail VWCD ON VWCD.CourseId = @courseId
			INNER JOIN dbo.VenueAddress VA ON VWCD.VenueId = VA.VenueId
			INNER JOIN dbo.[Location] L ON VA.LocationId = L.Id
			INNER JOIN dbo.OrganisationSelfConfiguration OSC ON VWCD.OrganisationId = OSC.OrganisationId
			INNER JOIN dbo.vwCourseSession CS ON VWCD.CourseId = CS.CourseId
												AND VWCD.SessionNumber = CS.SessionNumber
			INNER JOIN dbo.OrganisationEmailTemplateMessage OETM ON VWCD.OrganisationId = OETM.OrganisationId
																	AND OETM.Code = @templateCode
			WHERE T.Id = @trainerId;

		IF (@contentEmail IS NOT NULL AND @trainerEmailAddress IS NOT NULL)
		BEGIN
			SET @contentEmail = REPLACE(@contentEmail, @trainerDisplayNameTag, @trainerDisplayName);
			SET @contentEmail = REPLACE(@contentEmail, @courseTypeTag, @courseType);
			SET @contentEmail = REPLACE(@contentEmail, @courseReferenceTag, @courseReference);
			SET @contentEmail = REPLACE(@contentEmail, @courseVenueTitleTag, @courseVenueTitle);
			SET @contentEmail = REPLACE(@contentEmail, @courseVenueAddressTag, @courseVenueAddress);
			SET @contentEmail = REPLACE(@contentEmail, @courseStartDateTag, @courseStartDate);
			SET @contentEmail = REPLACE(@contentEmail, @courseEndDateTag, @courseEndDate);
			SET @contentEmail = REPLACE(@contentEmail, @courseSessionsTag, @courseSessions);


			IF(@subjectEmail IS NOT NULL)
			BEGIN
				SET @subjectEmail = REPLACE(@subjectEmail, @courseTypeTag, @courseType);
			END
			ELSE
			BEGIN
				SET @subjectEmail = @fallbackEmailSubject;
			END

			EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
								, @fromName = @atlasSystemFromName
								, @fromEmailAddresses = @atlasSystemFromEmail
								, @toEmailAddresses = @trainerEmailAddress
								, @bccEmailAddresses = @trainerNotificationBCCEmailAddress
								, @emailSubject = @subjectEmail
								, @emailContent = @contentEmail
								, @asapFlag = @emailASAPFlag
								, @sendAfterDateTime = @emailSendAfterDateTime
								, @organisationId = @orgId;
		END
		ELSE
		BEGIN
			SET @systemTrappedMessage = 'Could not proceed to email cancellation confirmation to TrainerId: ' + CAST(@trainerId AS VARCHAR) 
										+ '. Trainer Name: ' + @trainerDisplayName + ' for Course Id: ' + CAST(@courseId AS VARCHAR) 
										+ ' as email template content for Organisation is NULL or Trainer email address is not populated.' 
										+ ' This stored procedure was called from TRG_CourseTrainer_InsertUpdateDelete';

			INSERT INTO dbo.SystemTrappedError(FeatureName, DateRecorded, [Message])
			VALUES(@systemTrappedFeatureName, GETDATE(), @systemTrappedMessage);
		END
	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_19.01_AlterSP_uspCreateAndSendTrainerBookingConfirmation';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
