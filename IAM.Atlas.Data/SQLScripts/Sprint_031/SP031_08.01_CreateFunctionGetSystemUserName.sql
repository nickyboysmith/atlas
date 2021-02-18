/*
	SCRIPT: Create a function to return The Atlas System Name
	Author: Nick Smith
	Created: 28/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_08.01_CreateFunctionGetSystemUserName.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Atlas System Name';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetSystemUserName', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetSystemUserName;
	END		
	GO

	/*
		Create udfGetSystemUserName
	*/
	CREATE FUNCTION [dbo].[udfGetSystemUserName] ()
	RETURNS Varchar(320)
	AS
	BEGIN

		DECLARE @SystemUserName Varchar(320);

		SELECT @SystemUserName = Name 
		FROM [USER] 
		WHERE Id = dbo.udfGetSystemUserId() 


		RETURN @SystemUserName;
		
	END

	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_08.01_CreateFunctionGetSystemUserName.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





