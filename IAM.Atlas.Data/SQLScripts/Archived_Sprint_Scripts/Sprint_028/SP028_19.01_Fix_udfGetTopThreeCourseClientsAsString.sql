/*
	SCRIPT: Fix the function to return The Top 3 Course Clients in string format
	Author: Robert Newnham
	Created: 24/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_19.01_Fix_udfGetTopThreeCourseClientsAsString.sql';
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
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.udfGetTopThreeCourseClientsAsString', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.udfGetTopThreeCourseClientsAsString;
END		
GO

	/*
		Create udfGetTopThreeCourseClientsAsString
	*/
	CREATE FUNCTION udfGetTopThreeCourseClientsAsString (@CourseId int)
	RETURNS varchar(1000)
	AS
	BEGIN
		DECLARE @Clients AS VARCHAR(1000) = ''; 
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @Tab VARCHAR(1) = CHAR(9);
	
		SELECT TOP 3 
			@Clients = @Clients + (CASE WHEN LEN(@Clients) > 0 THEN @NewLine ELSE '' END)
								+ CONVERT(varchar(10),CC.ClientId)
								+ @Tab + CAST (CC.DateAdded AS VARCHAR)
								+ @Tab + C.DisplayName
		FROM dbo.CourseClient CC
		INNER JOIN dbo.Client C ON CC.ClientId = C.Id
		WHERE  CC.CourseId = @CourseId;
	
		SET @Clients = (CASE WHEN LEN(@Clients) > 0 THEN @Clients ELSE '*NONE*' END);
		RETURN @Clients;
		
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP028_19.01_Fix_udfGetTopThreeCourseClientsAsString.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





