/*
	SCRIPT: Amend a stored procedure to clone course
	Author: John Cocklin
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_07.03_Amend_SP_uspCreateCourseClone.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to clone course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateCourseClone', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateCourseClone;
END		
GO

	/*
		Create uspCreateCourseClone
	*/

	CREATE PROCEDURE dbo.uspCreateCourseClone @courseCloneRequestId INT
											, @courseId INT
											, @startDate DATETIME
											, @endDate DATETIME
											, @courseReferenceGeneratorId INT NULL
											, @useSameReference BIT NULL = 'False'
											, @useSameTrainers BIT NULL = 'False'
			
	AS
	BEGIN

		DECLARE @courseTypeId INT
			  , @DefaultStartTime VARCHAR(5)
			  , @DefaultEndTime VARCHAR(5)
			  , @available BIT 
			  , @organisationId INT
			  , @reference VARCHAR(100)
			  , @trainersRequired INT
			  , @sendattendanceDORS BIT
			  , @trainerUpdatedAttendance BIT
			  , @manualCarsOnly BIT
			  , @onlineManualCarsOnly BIT
			  , @dateUpdated DATETIME
			  , @courseTypeCategoryId INT
			  , @lastBookingDate DATETIME
			  , @attendanceCheckRequired BIT
			  , @dateAttendanceSentToDORS DATETIME
			  , @attendanceSentToDORS BIT
			  , @attendanceCheckVerified BIT
			  , @DORSCourse BIT
			  , @DORSNotificationRequested BIT
			  , @DORSNotified BIT
			  , @dateDORSNotified DATETIME
			  , @newReference VARCHAR(100)
			  , @referenceCode VARCHAR(4)
			  , @trainerId INT
			  , @newCourseId INT
			  , @prefix VARCHAR(40)
			  , @suffix VARCHAR(40)
			  , @separator VARCHAR(4)
			  , @venueCode VARCHAR(20)
			  , @courseTypeCode VARCHAR(20)
			  , @requestedByUserId INT
			  , @PracticalCourse BIT
			  , @TheoryCourse BIT


		SELECT @courseTypeId = c.CourseTypeId
			 , @DefaultStartTime =  c.DefaultStartTime
			 , @DefaultEndTime = c.DefaultEndTime
			 , @available = c.Available
			 , @organisationId = c.OrganisationId
			 , @reference = c.Reference
			 , @trainersRequired = c.TrainersRequired
			 , @sendattendanceDORS = c.sendattendanceDORS
			 , @trainerUpdatedAttendance = c.trainerUpdatedAttendance
			 , @manualCarsOnly = c.manualCarsOnly
			 , @onlineManualCarsOnly = c.onlineManualCarsOnly
			 , @dateUpdated = c.dateUpdated
			 , @courseTypeCategoryId = c.courseTypeCategoryId
			 , @lastBookingDate = c.lastBookingDate
			 , @attendanceCheckRequired = c.attendanceCheckRequired
			 , @dateAttendanceSentToDORS = c.dateAttendanceSentToDORS
			 , @attendanceSentToDORS = c.attendanceSentToDORS
			 , @attendanceCheckVerified = c.attendanceCheckVerified
			 , @DORSCourse = c.DORSCourse
			 , @DORSNotificationRequested = c.DORSNotificationRequested
			 , @DORSNotified = c.DORSNotified
			 , @dateDORSNotified = c.dateDORSNotified
			 , @PracticalCourse = c.PracticalCourse
			 , @TheoryCourse = c.TheoryCourse
		FROM dbo.Course c
		WHERE Id = @courseId;

		SELECT @requestedByUserId = requestedByUserId
		FROM dbo.CourseCloneRequest
		WHERE Id = @courseCloneRequestId

		--Gets the applicable code associated with Id to pass to the reference generator stored procedure.
		IF (@courseReferenceGeneratorId IS NOT NULL)
		BEGIN
			SELECT @referenceCode = crg.Code
			FROM dbo.CourseReferenceGenerator crg
			WHERE Id = @courseReferenceGeneratorId;
		END

		--If a new reference is required then call refgen stored proc
		IF (@useSameReference = 'False' AND @referenceCode IS NOT NULL)
		BEGIN
			---Get Prefix Suffix and Separator for use with Course Ref Generator Stored Proc.
			SELECT @prefix = prefix
				 , @suffix = suffix
				 , @separator = separator
			FROM dbo.CourseReferencePrefixSuffixSeparator
			WHERE OrganisationId = @organisationId;

			-- Get course type code for stored proc
			SELECT @courseTypeCode = Code
			FROM dbo.CourseType
			WHERE Id = @courseTypeId;

			--Get Venue Code
			SELECT @venueCode = Code
			FROM dbo.Venue v 
			INNER JOIN dbo.VenueCourseType vct ON v.id = vct.VenueId
			WHERE vct.CourseTypeId = @courseTypeId;
			
			-- Call stored proc with gathered info
			EXEC uspCourseReferenceGenerator @referenceCode, @organisationId, @prefix, @suffix, @separator, @venueCode, @courseTypeCode, @newReference OUTPUT; --REF CODE
		END

		-- If the same reference is required, set @newReference to the reference held in the original course.
		IF (@useSameReference = 'True')
		BEGIN
			SET @newReference = @reference;
		END

		--If the same trainer is required then fetch id
		IF (@useSameTrainers = 'True')
		BEGIN
			SELECT @trainerId = ct.TrainerId
			FROM Course c 
			INNER JOIN dbo.CourseTrainer ct ON c.Id = ct.CourseId
			WHERE c.Id = @courseId;
		END
			
		INSERT INTO dbo.Course
				   (CourseTypeId
				   ,DefaultStartTime
				   ,DefaultEndTime
				   ,OrganisationId
				   ,Available
				   ,Reference
				   ,TrainersRequired
				   ,SendAttendanceDORS
				   ,TrainerUpdatedAttendance
				   ,ManualCarsOnly
				   ,OnlineManualCarsOnly
				   ,CreatedByUserId
				   ,DateUpdated
				   ,CourseTypeCategoryId
				   ,LastBookingDate
				   ,AttendanceCheckRequired
				   ,DORSCourse
				   ,DateDORSNotified
				   ,PracticalCourse
				   ,TheoryCourse)

		VALUES (@courseTypeId
			  , @DefaultStartTime
			  , @DefaultEndTime
			  , @organisationId 
			  , 0 -- BA said to default to false
			  , @newReference
			  , @trainersRequired 
			  , @sendattendanceDORS 
			  , @trainerUpdatedAttendance 
			  , @manualCarsOnly 
			  , @onlineManualCarsOnly 
			  , @requestedByUserId 
			  , GETDATE() -- DateUpdated
			  , @courseTypeCategoryId 
			  , @lastBookingDate 
			  , @attendanceCheckRequired 
			  , @DORSCourse 
			  , @dateDORSNotified
			  , @PracticalCourse
			  , @TheoryCourse)

		SET @newCourseId = SCOPE_IDENTITY();

		--Insert into course date
		DECLARE @AssociatedSessionNumber INT

		SELECT @AssociatedSessionNumber = cd.AssociatedSessionNumber
		FROM dbo.CourseDate cd
		WHERE CourseId = @courseId;
		
		INSERT INTO dbo.CourseDate
				   (CourseId
				   ,DateStart
				   ,DateEnd
				   ,Available
				   ,CreatedByUserId
				   ,DateUpdated
				   ,AssociatedSessionNumber)
		VALUES (@newCourseId
			   , @startDate 
			   , @endDate
			   , 0
			   , @requestedByUserId
			   , GETDATE()
			   , @AssociatedSessionNumber);

		--Insert into course venue
		INSERT INTO dbo.CourseVenue
				   (CourseId
				   ,VenueId
				   ,MaximumPlaces
				   ,ReservedPlaces
				   ,VenueLocaleId
				   ,EmailAvailability
				   ,AvailabilityEmailed
				   ,DateAvailabilityEmailed)
		SELECT	   @newCourseId
				   , cv.VenueId
				   , cv.MaximumPlaces
				   , cv.ReservedPlaces
				   , cv.VenueLocaleId
				   , 0
				   , 0
				   , NULL
		FROM CourseVenue cv
		WHERE CourseId = @courseId


		--Insert into course language
		INSERT INTO dbo.CourseLanguage
				   (CourseId
				   ,OrganisationLanguageId)
		SELECT	   @newCourseId
				   , cl.OrganisationLanguageId
		FROM CourseLanguage cl
		WHERE CourseId = @courseId


		--Update CourseCloneRequest
		UPDATE dbo.CourseCloneRequest
		SET NewCoursesCreated = 'True'
		  , DateNewCoursesCreated = GETDATE()
		WHERE Id = @CourseCloneRequestId

		-- Insert new info into CourseClonedCourse
		INSERT INTO dbo.CourseClonedCourse
				   (CourseCloneRequestId
				   ,NewCourseId
				   ,DateCreated)

		VALUES (@courseCloneRequestId
			  , @newCourseId
			  , GETDATE())

		--Insert into course trainer if 'use same trainer' was ticked and 
		-- trainerId variable was populated in above query.
		IF (@trainerId IS NOT NULL)
		BEGIN
			INSERT INTO dbo.CourseTrainer(CourseId
										, TrainerId
										, DateCreated
										, CreatedByUserId
										, BookedForTheory
										, BookedForPractical)

			SELECT @newCourseId
				 , TrainerId
				 , GETDATE()
				 , @requestedByUserId
				 , BookedForTheory
				 , BookedForPractical
			FROM dbo.CourseTrainer 
			WHERE CourseId = @courseId

		END

	END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP033_07.03_Amend_SP_uspCreateCourseClone.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
