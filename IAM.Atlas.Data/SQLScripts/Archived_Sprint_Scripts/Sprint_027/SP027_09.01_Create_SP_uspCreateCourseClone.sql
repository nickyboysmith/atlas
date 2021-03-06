/*
	SCRIPT: Create a stored procedure to clone course
	Author: Dan Hough
	Created: 05/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_09.01_Create_SP_uspCreateCourseClone.sql';
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
											, @useSameReference BIT NULL
											, @useSameTrainers BIT NULL
			
	AS
	BEGIN

		DECLARE @courseTypeId INT
			  , @available BIT 
			  , @organisationId INT
			  , @reference VARCHAR(100)
			  , @trainersRequired INT
			  , @sendattendanceDORS BIT
			  , @trainerUpdatedAttendance BIT
			  , @manualCarsOnly BIT
			  , @onlineManualCarsOnly BIT
			  , @createdByUserId INT
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
			  , @newCourseId INT;

		SELECT @courseTypeId = c.CourseTypeId
			 , @available = c.Available
			 , @organisationId = c.OrganisationId
			 , @reference = c.Reference
			 , @trainersRequired = c.TrainersRequired
			 , @sendattendanceDORS = c.sendattendanceDORS
			 , @trainerUpdatedAttendance = c.trainerUpdatedAttendance
			 , @manualCarsOnly = c.manualCarsOnly
			 , @onlineManualCarsOnly = c.onlineManualCarsOnly
			 , @createdByUserId = c.createdByUserId
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
		FROM dbo.Course c
		WHERE Id = @courseId;

		--Gets the applicable code associated with Id to pass to the reference generator stored procedure.
		IF (@courseReferenceGeneratorId IS NOT NULL)
		BEGIN
			SELECT @referenceCode = crg.Code
			FROM dbo.CourseReferenceGenerator crg
			WHERE Id = @courseReferenceGeneratorId;
		END

		--If a new reference is required then call refgen stored proc
		IF (@useSameReference = 'False' OR 
			@useSameReference IS NULL AND 
			@referenceCode IS NOT NULL)
		BEGIN
			EXEC uspCourseReferenceGenerator @referenceCode, @newReference OUTPUT; --REF CODE
		END

		-- If the same reference is required, set @referenceCode to the reference held in the original course.
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
				   ,DateDORSNotified)

		VALUES( @courseTypeId
			  , CAST(CAST(@startDate AS TIME) AS VARCHAR(5)) -- passed through to this stored proc
			  , CAST(CAST(@endDate AS TIME) AS VARCHAR(5)) --passed through to this stored proc
			  , @organisationId 
			  , @newReference
			  , @trainersRequired 
			  , @sendattendanceDORS 
			  , @trainerUpdatedAttendance 
			  , @manualCarsOnly 
			  , @onlineManualCarsOnly 
			  , @createdByUserId 
			  , GETDATE() -- DateUpdated
			  , @courseTypeCategoryId 
			  , @lastBookingDate 
			  , @attendanceCheckRequired 
			  , @DORSCourse 
			  , @dateDORSNotified);

		SET @newCourseId = SCOPE_IDENTITY();

		--Insert into course date
		INSERT INTO dbo.CourseDate
				   (CourseId
				   ,DateStart
				   ,DateEnd
				   ,CreatedByUserId
				   ,DateUpdated)
		VALUES
			   ( @newCourseId
			   , CAST(@startDate AS TIME)
			   , CAST(@endDate AS TIME)
			   , @createdByUserId
			   , GETDATE());

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
										, CreatedByUserId)
			VALUES(@newCourseId
				 , @trainerId
				 , GETDATE()
				 , @createdByUserId);
		END

	END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP027_09.01_Create_SP_uspCreateCourseClone.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
