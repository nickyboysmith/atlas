/*
	SCRIPT: Create a function to return The Max Number Emails To Process Per Day
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_26.03_CreateFunctionGetMaxNumberEmailsesToProcsPerDay.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Max Number Emails To Process Per Day';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetMaxNumberEmailsToProcessPerDay', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetMaxNumberEmailsToProcessPerDay;
	END		
	GO

	/*
		Create udfGetMaxNumberEmailsToProcessPerDay
	*/
	CREATE FUNCTION udfGetMaxNumberEmailsToProcessPerDay ()
	RETURNS INT
	AS
	BEGIN
		DECLARE @udfGetMaxNumberEmailsToProcessPerDay INT = 5000;
		SELECT @udfGetMaxNumberEmailsToProcessPerDay=[MaxNumberEmailsToProcessPerDay] FROM [dbo].[SystemControl] WHERE Id = 1;

		RETURN @udfGetMaxNumberEmailsToProcessPerDay;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_26.03_CreateFunctionGetMaxNumberEmailsesToProcsPerDay.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





