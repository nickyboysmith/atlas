/*
	SCRIPT: Create a function to return course clients in string format
	Author: Dan Murray
	Created: 30/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_17.02_Fix_ufn_GetCourseClientsAsString.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return course clients in string format';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.ufn_GetCourseClientsAsString', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.ufn_GetCourseClientsAsString;
END		
GO

/*
	Create ufn_GetCourseClientsAsString
*/
CREATE FUNCTION ufn_GetCourseClientsAsString (@CourseId int)
RETURNS varchar(1000)
AS
BEGIN
	DECLARE @Clients AS VARCHAR(1000); 
	SET @Clients = ''; 
	
	SELECT TOP 3 @Clients = @Clients +  CONVERT(varchar(10),CC.ClientId) + CHAR(9) 
										   +  CAST (CC.DateAdded AS VARCHAR) + CHAR(9) 
										   + C.FirstName + ' ' + C.Surname + CHAR(13) + CHAR(10)
	FROM dbo.CourseClient CC
	LEFT JOIN dbo.Client C
	ON CC.ClientId = C.Id
	WHERE  CC.CourseId = @CourseId
	
	RETURN @Clients
		
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_17.02_Fix_ufn_GetCourseClientsAsString.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





