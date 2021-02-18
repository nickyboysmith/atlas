/*
	Post-Release.sql
	This script should be run every release.

	Date Created: 17/11/2016 By Dan Hough

*/

DECLARE @ScriptName VARCHAR(100) = 'Post-Release.sql';
DECLARE @ScriptComments VARCHAR(800) = 'This Script Ensures Certain Data rows exist in tables.';


/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
	
	DECLARE @majorVersionYear INT = 2016
		  , @majorVersionNumber INT = 1
		  , @applicationVersionPart2 INT
		  , @applicationVersionPart3 INT
		  , @applicationVersionPart4 FLOAT;

	SELECT @applicationVersionPart2 = ApplicationVersionPart2
		 , @applicationVersionPart3 = ApplicationVersionPart3
		 , @applicationVersionPart4 = ApplicationVersionPart4
	FROM dbo.SystemControl 
	WHERE ID = 1;

	SET @applicationVersionPart4 = @applicationVersionPart4 + 0.01;

	IF(@applicationVersionPart2 != DATEPART(YEAR, GETDATE()))
	BEGIN
		SET @applicationVersionPart3 = 1;
	END
	
	IF(DATEPART(YEAR, GETDATE()) = @majorVersionYear)
	BEGIN
		SET @applicationVersionPart3 = @majorVersionNumber;
	END

	UPDATE dbo.SystemControl
	SET SystemAvailable = 'True'
	  , SystemStatus = 'The system is accessible'
	  , SystemBlockedMessage = 'We''re currently having technical issues. Please retry shortly.'
	  , DateOfLastApplicationReleaseCompleted = GETDATE()
	  , ApplicationVersionPart2 = DATEPART(YEAR, GETDATE())
	  , ApplicationVersionPart3 = @applicationVersionPart3
	  , ApplicationVersionPart4 = @applicationVersionPart4
	WHERE Id = 1;

EXEC dbo.uspScriptCompleted @ScriptName; 
GO