/*
	SCRIPT: Create a function to return a surname from a UK Licence Number
	Author: Daniel Hough
	Created: 10/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_21.01_udfReturnSurnameFromUkLicenceNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a surname from a UK Licence Number';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfReturnSurnameFromUkLicenceNumber', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfReturnSurnameFromUkLicenceNumber;
	END		
	GO

	/*
		Create udfReturnSurnameFromUkLicenceNumber
	*/
	CREATE FUNCTION dbo.udfReturnSurnameFromUkLicenceNumber (@UKLicenceNumber AS VARCHAR(40))
	RETURNS VARCHAR(5)
	AS
	BEGIN
		DECLARE @surnameOnLicence VARCHAR(5);
		SELECT @surnameOnLicence = LEFT(@UKLicenceNumber, 5);

		--UK Licences start with 5 characters from a surname. If surname
		--is less than five characters it's padded with trailling nines.
		--this removes the nines.
		SELECT @surnameOnLicence = REPLACE(@surnameOnLicence, '9', '');

		RETURN @surnameOnLicence;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_21.01_udfReturnSurnameFromUkLicenceNumber.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO