/*
	SCRIPT: Create a function to return The Internal Message Category Id with a Name
	Author: Robert Newnham
	Created: 05/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_21.01_CreateFunctionGetMessageCategoryId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The Message Category Id';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetMessageCategoryId', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetMessageCategoryId;
	END		
	GO

	/*
		Create udfGetMessageCategoryId
	*/
	CREATE FUNCTION udfGetMessageCategoryId (@CategoryName VARCHAR(100) = 'GENERAL')
	RETURNS int
	AS
	BEGIN
		DECLARE @MessageCategoryId int;
		SELECT @MessageCategoryId=[Id] FROM [dbo].[MessageCategory] WHERE [Name] = @CategoryName;

		RETURN @MessageCategoryId;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_21.01_CreateFunctionGetMessageCategoryId.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





