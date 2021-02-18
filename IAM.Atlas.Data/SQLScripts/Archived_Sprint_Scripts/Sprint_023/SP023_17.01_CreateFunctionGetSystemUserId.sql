/*
	SCRIPT: Create a function to return The System User Id
	Author: Robert Newnham
	Created: 15/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_17.01_CreateFunctionGetSystemUserId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The System User Id';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetSystemUserId', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetSystemUserId;
	END		
	GO

	/*
		Create udfGetSystemUserId
	*/
	CREATE FUNCTION udfGetSystemUserId ()
	RETURNS int
	AS
	BEGIN
		DECLARE @SystemUserId int;
		SELECT @SystemUserId=[AtlasSystemUserId] FROM [dbo].[SystemControl] WHERE Id = 1;

		RETURN @SystemUserId;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_17.01_CreateFunctionGetSystemUserId.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





