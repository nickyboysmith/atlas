/*
	SCRIPT: Create a function to Split a Word With Upper Case Characters into it's Words
	Author: Dan Hough
	Created: 02/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_20.01_CreateFunctionudfSplitStringUsingCustomSeparator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to split a separated string';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfSplitStringUsingCustomSeparator', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfSplitStringUsingCustomSeparator;
	END		
	GO

	CREATE FUNCTION [dbo].[udfSplitStringUsingCustomSeparator](@Input NVARCHAR(MAX),@Character CHAR(1))
	RETURNS @Output TABLE (Item NVARCHAR(1000))

	/* Splits a separated string in to different rows.
		To Use:

		Ex. 1
		SELECT Item
		FROM dbo.SplitCommaSeparatedString('Id, Name, Description, Value1, Value2, Value3', ',')

		Ex. 2
		SELECT Item
		FROM dbo.SplitCommaSeparatedString('Id+Name+Description+Value1+Value2+Value3', '+')

	*/

	AS
	BEGIN

		DECLARE @StartIndex INT, @EndIndex INT
 
		SET @StartIndex = 1
		IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
		BEGIN
			SET @Input = @Input + @Character
		END
 
		WHILE CHARINDEX(@Character, @Input) > 0
		BEGIN
			SET @EndIndex = CHARINDEX(@Character, @Input)
           
			INSERT INTO @Output(Item)
			SELECT RTRIM(LTRIM(SUBSTRING(@Input, @StartIndex, @EndIndex - 1)))
           
			SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
		END
 
	RETURN
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_20.01_CreateFunctionudfSplitStringUsingCustomSeparator.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
