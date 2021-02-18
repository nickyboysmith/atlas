/*
	SCRIPT: Create a function to convert a postcode to a postcode area
	Author: Dan Murray
	Created: 05/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_03.01_Create_ufn_GetPostCodeArea.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to convert a postcode to a postcode area';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.ufn_GetPostCodeArea', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.ufn_GetPostCodeArea;
END		
GO

/*
	Create ufn_GetPostCodeArea
*/
CREATE FUNCTION ufn_GetPostCodeArea (@PostCode varchar(10))
RETURNS varchar(10)
AS
BEGIN
	
	DECLARE @postcodearea varchar(10);	

	SELECT @postcodearea =  SUBSTRING ( @PostCode ,1 , LEN(@PostCode) - 3);
		
	RETURN	REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE (SUBSTRING(@postcodearea,1,2), '0', ''),
			'1', ''),
			'2', ''),
			'3', ''),
			'4', ''),
			'5', ''),
			'6', ''),
			'7', ''),
			'8', ''),
			'9', '');
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP014_03.01_Create_ufn_GetPostCodeArea.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
