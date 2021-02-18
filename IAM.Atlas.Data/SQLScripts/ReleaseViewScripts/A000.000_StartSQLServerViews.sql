/*
	SCRIPT: All SQL Server Views are saved here. Should be refreshed after every database release.
	Author: The Whole Team
	Updated
*/ 

DECLARE @ScriptName VARCHAR(100) = 'SQLServerViews.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Start the of the SQL Server Views';


/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO
