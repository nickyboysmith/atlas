/*
	SCRIPT: Create a function to return The System From Email Name
	Author: Robert Newnham
	Created: 10/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_25.02_CreateFunctionGetSystemEmailFromName.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The System User From Email Name';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetSystemEmailFromName', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetSystemEmailFromName;
	END		
	GO

	/*
		Create udfGetSystemEmailFromName
	*/
	CREATE FUNCTION udfGetSystemEmailFromName ()
	RETURNS VARCHAR(320)
	AS
	BEGIN
		DECLARE @AtlasSystemFromName VARCHAR(320);
		SELECT @AtlasSystemFromName=[AtlasSystemFromName] FROM [dbo].[SystemControl] WHERE Id = 1;

		RETURN @AtlasSystemFromName;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_25.02_CreateFunctionGetSystemEmailFromName.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





