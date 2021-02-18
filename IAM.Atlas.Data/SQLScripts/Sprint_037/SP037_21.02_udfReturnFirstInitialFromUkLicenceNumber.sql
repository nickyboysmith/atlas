/*
	SCRIPT: Create a function to return first initial from a UK Licence Number
	Author: Daniel Hough
	Created: 10/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_21.02_udfReturnFirstInitialFromUkLicenceNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return first initial from a UK Licence Number';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfReturnFirstInitialFromUkLicenceNumber', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfReturnFirstInitialFromUkLicenceNumber;
	END		
	GO

	/*
		Create udfReturnFirstInitialFromUkLicenceNumber
	*/
	CREATE FUNCTION dbo.udfReturnFirstInitialFromUkLicenceNumber (@UKLicenceNumber AS VARCHAR(40))
	RETURNS CHAR(1)
	AS
	BEGIN
		DECLARE @firstInitial CHAR(1);
		SELECT @firstInitial = SUBSTRING(@UKLicenceNumber, 12, 1);

		RETURN @firstInitial;
	END

GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_21.02_udfReturnFirstInitialFromUkLicenceNumber.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO