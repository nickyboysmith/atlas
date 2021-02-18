/*
	SCRIPT: Create a function to return The Max Number Emails To Process At Once
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_26.02_CreateFunctionGetMaxNumberEmailsToProcessAtOnce.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Max Number Emails To Process At Once';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetMaxNumberEmailsToProcessAtOnce', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetMaxNumberEmailsToProcessAtOnce;
	END		
	GO

	/*
		Create udfGetMaxNumberEmailsToProcessAtOnce
	*/
	CREATE FUNCTION udfGetMaxNumberEmailsToProcessAtOnce ()
	RETURNS INT
	AS
	BEGIN
		DECLARE @udfGetMaxNumberEmailsToProcessAtOnce INT = 500;
		SELECT @udfGetMaxNumberEmailsToProcessAtOnce=[MaxNumberEmailsToProcessAtOnce] FROM [dbo].[SystemControl] WHERE Id = 1;

		RETURN @udfGetMaxNumberEmailsToProcessAtOnce;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_26.02_CreateFunctionGetMaxNumberEmailsToProcessAtOnce.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





