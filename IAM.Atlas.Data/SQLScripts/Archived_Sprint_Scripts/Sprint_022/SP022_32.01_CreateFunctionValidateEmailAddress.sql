
/*
	SCRIPT: Create Function That will Validate an Email Address
	Author: Robert Newnham
	Created: 04/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_32.01_CreateFunctionValidateEmailAddress.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Function That will Validate an Email Address';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfIsEmailAddressValid', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfIsEmailAddressValid;
	END		
	GO

	CREATE FUNCTION dbo.udfIsEmailAddressValid(@emailAddress varchar(320))
	RETURNS bit
	AS
	BEGIN
		DECLARE @returnValue bit;
		SET @returnValue = 'False';
		IF (@emailAddress LIKE '%_@__%.__%') 
		BEGIN
			SET @returnValue = 'True';
		END
		RETURN @returnValue;
	END
		

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP022_32.01_CreateFunctionValidateEmailAddress.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO