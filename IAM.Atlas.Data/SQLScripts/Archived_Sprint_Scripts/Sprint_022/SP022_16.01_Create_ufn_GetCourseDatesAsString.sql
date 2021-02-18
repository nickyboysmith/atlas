/*
	SCRIPT: Create a function to return course dates in string format
	Author: Dan Murray
	Created: 30/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_16.01_Create_ufn_GetCourseDatesAsString.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return course dates in string format';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.ufn_GetCourseDatesAsString', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.ufn_GetCourseDatesAsString;
END		
GO

/*
	Create ufn_GetCourseDatesAsString
*/
CREATE FUNCTION ufn_GetCourseDatesAsString (@CourseId int)
RETURNS varchar(1000)
AS
BEGIN
	DECLARE @Dates AS VARCHAR(1000); 
	SET @Dates = ''; 
	
	SELECT TOP 10 @Dates = @Dates + ',' + CAST (CD.DateStart AS VARCHAR) 
	FROM dbo.CourseDate CD
	WHERE  CD.CourseId = @CourseId
	
	RETURN @Dates
		
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_16.01_Create_ufn_GetCourseDatesAsString.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





