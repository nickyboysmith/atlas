/*
	SCRIPT: Create a function to return a Course's first Course Date
	Author: Robert Newnham
	Created: 10/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_25.01_CreateFunctionGetFirstCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a Courses first Course Date';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetFirstCourseDate', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetFirstCourseDate;
	END		
	GO

	/*
		Create udfGetFirstCourseDate
	*/
	CREATE FUNCTION udfGetFirstCourseDate (@CourseId INT)
	RETURNS DateTime
	AS
	BEGIN
		DECLARE @FirstCourseDate DateTime;

		SELECT @FirstCourseDate=MIN(CD1.DateStart)
		FROM dbo.CourseDate CD1
		WHERE CD1.CourseId = @CourseId 
		AND CD1.DateStart IS NOT NULL;

		RETURN @FirstCourseDate;		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_25.01_CreateFunctionGetFirstCourseDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





