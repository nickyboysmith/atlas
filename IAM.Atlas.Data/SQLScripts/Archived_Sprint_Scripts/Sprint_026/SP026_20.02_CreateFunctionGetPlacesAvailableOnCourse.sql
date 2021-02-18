/*
	SCRIPT: Create a function to return The MNumber of Places Available on a Course
	Author: Robert Newnham
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_20.02_CreateFunctionGetPlacesAvailableOnCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The MNumber of Places Available on a Course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.GetPlacesAvailableOnCourse', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.GetPlacesAvailableOnCourse;
	END		
	GO
	IF OBJECT_ID('dbo.udfGetPlacesAvailableOnCourse', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetPlacesAvailableOnCourse;
	END		
	GO

	/*
		Create udfGetPlacesAvailableOnCourse
	*/
	CREATE FUNCTION udfGetPlacesAvailableOnCourse (@CourseId INT)
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
		FROM Course C
		INNER JOIN CourseVenue CV ON CV.CourseId = C.Id
		INNER JOIN Venue V ON CV.VenueId = V.Id
		LEFT JOIN CancelledCourse CC ON CC.CourseId = C.Id
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

		RETURN (@MaxNumberOfAttendeesForCourse - ISNULL(@NumberOfBookedClients,0));
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP026_20.02_CreateFunctionGetPlacesAvailableOnCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





