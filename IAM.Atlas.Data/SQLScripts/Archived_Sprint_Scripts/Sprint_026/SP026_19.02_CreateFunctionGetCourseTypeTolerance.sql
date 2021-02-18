/*
	SCRIPT: Create a function to return The Attendees Based on the Course Type and Number of Trainers
	Author: Robert Newnham
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_19.02_CreateFunctionGetCourseTypeTolerance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Attendees Based on the Course Type and Number of Trainers';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetCourseTypeTolerance', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetCourseTypeTolerance;
	END		
	GO

	/*
		Create udfGetCourseTypeTolerance
	*/
	CREATE FUNCTION udfGetCourseTypeTolerance (@CourseTypeId INT, @NumberOfTrainers INT)
	RETURNS int
	AS
	BEGIN
		DECLARE @MaxNumberOfAttendeesForCourseType INT = 0
				, @FirstRatio INT
				, @SecondRatio INT
				, @MaximumAttendees INT
				, @Tolerance INT
				;

		SELECT TOP 1
			@FirstRatio=FirstRatio
			, @SecondRatio=SecondRatio
			, @MaximumAttendees=MaximumAttendees
			, @Tolerance=Tolerance
		FROM dbo.CourseTypeTolerance
		WHERE CourseTypeId = @CourseTypeId
		AND EffectiveDate <= GetDate()
		ORDER BY EffectiveDate DESC;

		SET @MaxNumberOfAttendeesForCourseType = (((@NumberOfTrainers * @SecondRatio) / @FirstRatio) + @Tolerance);

		IF (@MaxNumberOfAttendeesForCourseType > @MaximumAttendees)
		BEGIN
			SET @MaxNumberOfAttendeesForCourseType = @MaximumAttendees;
		END

		RETURN @MaxNumberOfAttendeesForCourseType;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP026_19.02_CreateFunctionGetCourseTypeTolerance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





