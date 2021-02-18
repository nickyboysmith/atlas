/*
	SCRIPT: Create a function to Split a Word With Upper Case Characters into it's Words
	Author: Robert Newnham
	Created: 26/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_17.01_CreateFunctionudfSplitSingleWordIntoMultiple.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to Split a Word With Upper Case Characters into it''s Words';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfSplitSingleWordIntoMultiple', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfSplitSingleWordIntoMultiple;
	END		
	GO

	CREATE FUNCTION [dbo].[udfSplitSingleWordIntoMultiple] ( @InputString VARCHAR(4000) ) 
		RETURNS VARCHAR(4000)
		AS
		BEGIN
			/* This Function will Split a Word With Upper Case Characters into it's Words
				IE "ThisIsWhereWeStart" would become "This Is Where We Start" */
			DECLARE @Index          INT;
			DECLARE @Char           CHAR(1);
			DECLARE @OutputString   VARCHAR(255);

			SET @OutputString = @InputString;
			SET @Index = 1;

			WHILE @Index <= LEN(@InputString)
			BEGIN
				SET @Char = SUBSTRING(@InputString, @Index, 1);
	
				IF (@Index = 1)
				BEGIN
					--First Character
					SET @OutputString = @Char;
				END
				ELSE 
				BEGIN
					IF (UNICODE(@Char) = UNICODE(LOWER(@Char)))
					BEGIN
						--Lower Case Letter or Non Numeric
						SET @OutputString = @OutputString + @Char;
					END
					ELSE
					BEGIN
						--Upper Case Letter
						SET @OutputString = @OutputString + ' ' + @Char;
					END
				END

				SET @Index = @Index + 1;
			END

			RETURN @OutputString;

		END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP036_17.01_CreateFunctionudfSplitSingleWordIntoMultiple.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
