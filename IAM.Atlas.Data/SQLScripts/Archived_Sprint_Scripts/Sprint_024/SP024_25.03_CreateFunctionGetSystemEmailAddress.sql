/*
	SCRIPT: Create a function to return The System From Email Address
	Author: Robert Newnham
	Created: 10/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_25.03_CreateFunctionGetSystemEmailAddress.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The System User From Email Address';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetSystemEmailAddress', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetSystemEmailAddress;
	END		
	GO

	/*
		Create udfGetSystemEmailAddress
	*/
	CREATE FUNCTION udfGetSystemEmailAddress ()
	RETURNS VARCHAR(320)
	AS
	BEGIN
		DECLARE @AtlasSystemEmailAddress VARCHAR(320);
		SELECT @AtlasSystemEmailAddress=[AtlasSystemFromEmail] FROM [dbo].[SystemControl] WHERE Id = 1;

		RETURN @AtlasSystemEmailAddress;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_25.03_CreateFunctionGetSystemEmailAddress.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





