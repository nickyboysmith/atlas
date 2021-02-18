/*
	Pre-Release.sql
	This script should be run every release.

	Date Created: 17/11/2016 By Dan Hough

*/

DECLARE @ScriptName VARCHAR(100) = 'Pre-Release.sql';
DECLARE @ScriptComments VARCHAR(800) = 'This Script sets values on SystemControl before release';


/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 

	UPDATE dbo.SystemControl
	SET SystemAvailable = 'False'
	  , SystemStatus = 'New Atlas System Upgrade is in progress ......'
	  , SystemBlockedMessage = 'New Atlas System Upgrade is in progress ......'
	  , DateOfLastApplicationReleaseStarted = GETDATE()
	WHERE Id = 1;

EXEC dbo.uspScriptCompleted @ScriptName; 
GO