/*
	SCRIPT: Create a function to return The Maximum Number of Places on a Course
	Author: Robert Newnham
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_20.01_CreateFunctionGetMaxPlacesOnCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Maximum Number of Places on a Course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetMaxPlacesOnCourse', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetMaxPlacesOnCourse;
	END		
	GO

	/*
		Create udfGetCourseTypeTolerance
	*/
	CREATE FUNCTION udfGetMaxPlacesOnCourse (@CourseId INT)
	RETURNS int
	AS
	BEGIN
		DECLARE @MaxNumberOfAttendeesForCourse INT
			, @CourseTypeId INT
			, @NumberOfTrainers INT
			, @MaximumVenuePlaces INT
			, @ReservedVenuePlaces INT
			, @NumberOfBookedClients INT
			, @CourseCancelled BIT
			;
		
		SELECT
			@MaximumVenuePlaces=CV.MaximumPlaces
			, @ReservedVenuePlaces=CV.ReservedPlaces
			, @CourseCancelled=(CASE WHEN CC.Id IS NULL THEN 'False' ELSE 'True' END)
			, @CourseTypeId=@CourseTypeId
			, @NumberOfTrainers=TrainerList.NumberOfTrainers
		FROM Course C
		INNER JOIN CourseVenue CV ON CV.CourseId = C.Id
		INNER JOIN Venue V ON CV.VenueId = V.Id
		LEFT JOIN CancelledCourse CC ON CC.CourseId = C.Id
		LEFT JOIN vwCourseTrainerConactenatedTrainers_SubView TrainerList ON TrainerList.CourseId = C.id
		WHERE C.Id = @CourseId;

		SET @MaxNumberOfAttendeesForCourse = dbo.udfGetCourseTypeTolerance(@CourseTypeId, @NumberOfTrainers);

		IF (ISNULL(@MaxNumberOfAttendeesForCourse,0) <= 0 OR @MaxNumberOfAttendeesForCourse > @MaximumVenuePlaces)
		BEGIN
			SET @MaxNumberOfAttendeesForCourse = ISNULL(@MaximumVenuePlaces,0);
		END

		IF (@CourseCancelled='True')
		BEGIN
			SET @MaxNumberOfAttendeesForCourse = 0;
		END

		RETURN @MaxNumberOfAttendeesForCourse;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP026_20.01_CreateFunctionGetMaxPlacesOnCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





