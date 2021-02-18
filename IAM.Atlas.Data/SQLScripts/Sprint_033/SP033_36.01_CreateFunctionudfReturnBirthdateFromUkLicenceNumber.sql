/*
	SCRIPT: Create a function to return a birthdate from a UK Licence number
	Author: Daniel Hough
	Created: 20/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_36.01_CreateFunctionudfReturnBirthdateFromUkLicenceNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a birthdate from a UK Licence number';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfReturnBirthdateFromUkLicenceNumber', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfReturnBirthdateFromUkLicenceNumber;
	END		
	GO

	/*
		Create udfReturnBirthdateFromUkLicenceNumber
	*/
	CREATE FUNCTION dbo.udfReturnBirthdateFromUkLicenceNumber (@UKLicenceNumber AS VARCHAR(40))
	RETURNS DATE
	AS
	BEGIN
		DECLARE @dobOriginalFormat CHAR(6)
				, @month CHAR(2)
				, @day CHAR(2)
				, @year CHAR(2)
				, @dob DATE
				, @errorMessage varchar(100) = 'Cannot convert inputted licence to date. Check to see if it''s a valid UK Licence'
				, @true BIT = 1;


		--Gets the dob string in its original format
		SELECT @dobOriginalFormat = SUBSTRING(@UKLicenceNumber, 6, 6);

		--extracts month
		SELECT @month = SUBSTRING(@dobOriginalFormat, 2, 2);

		/* If licence belongs to a female, the month format is changed 
			so 51 is January, 52 February, 60 October, 61 November etc.
			This amends it to the correct date */
		IF (ISNUMERIC(@month) = 1)
		BEGIN
			IF (@month BETWEEN 51 AND 62)
			BEGIN
				IF (@month BETWEEN 51 AND 59)
				BEGIN
					--January to Sept
					SELECT @month = '0' + RIGHT(@month, 1);
				END
				ELSE
				BEGIN
					--October to Dec
					SELECT @month = '1' + RIGHT(@month, 1);
				END
			END
		END

		SELECT @day = SUBSTRING(@dobOriginalFormat, 4, 2);
		SELECT @year = left(@dobOriginalFormat, 1) + RIGHT(@dobOriginalFormat, 1);

		IF (ISNUMERIC(@day) = @true AND ISNUMERIC(@month) = @true AND ISNUMERIC(@year) = @true)
		BEGIN
			SELECT @dob = CAST(@year + @month + @day AS DATE);
		END
		ELSE
		BEGIN
			SELECT @dob = NULL;
		END

		RETURN @dob;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_36.01_CreateFunctionudfReturnBirthdateFromUkLicenceNumber.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





