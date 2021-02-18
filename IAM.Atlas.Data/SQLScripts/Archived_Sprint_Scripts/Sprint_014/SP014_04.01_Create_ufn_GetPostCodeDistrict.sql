/*
	SCRIPT: Create a function to convert a postcode to a postcode district
	Author: Dan Murray
	Created: 05/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_04.01_Create_ufn_GetPostCodeDistrict.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to convert a postcode to a postcode district';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.ufn_GetPostCodeDistrict', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.ufn_GetPostCodeDistrict;
END		
GO

/*
	Create ufn_GetPostCodeArea
*/
CREATE FUNCTION ufn_GetPostCodeDistrict (@PostCode varchar(10))
RETURNS varchar(10)
AS
BEGIN
	RETURN SUBSTRING ( @PostCode ,1 , LEN(@PostCode) - 3); 
	
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP014_04.01_Create_ufn_GetPostCodeDistrict.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





