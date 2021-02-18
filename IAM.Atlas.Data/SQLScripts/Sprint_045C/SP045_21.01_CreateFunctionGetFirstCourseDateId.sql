/*
	SCRIPT: Create a function to return a Course's first Course Date Id
	Author: Nick Smith
	Created: 04/12/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_21.01_CreateFunctionGetFirstCourseDateId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a Courses first CourseDateId';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetFirstCourseDateId', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetFirstCourseDateId;
	END		
	GO

	/*
		Create udfGetFirstCourseDate
	*/
	CREATE FUNCTION udfGetFirstCourseDateId (@CourseId INT)
	RETURNS INT
	AS
	BEGIN
		DECLARE @FirstCourseDateId INT;
		
		SELECT TOP 1 @FirstCourseDateId = CD1.Id
		FROM dbo.CourseDate CD1
		WHERE CD1.CourseId = @CourseId 
		AND CD1.DateStart IS NOT NULL
		ORDER BY CD1.DateStart

		RETURN @FirstCourseDateId;		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP045_21.01_CreateFunctionGetFirstCourseDateId.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





