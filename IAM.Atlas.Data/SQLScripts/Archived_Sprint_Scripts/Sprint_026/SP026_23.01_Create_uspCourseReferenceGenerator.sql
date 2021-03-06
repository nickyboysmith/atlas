/*
	SCRIPT: Create a Stored Procedure to generate a course reference
	Author: Dan Hough
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_23.01_Create_uspCourseReferenceGenerator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to generate a course reference';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseReferenceGenerator', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseReferenceGenerator;
END		
GO

/*
	Create uspCourseReferenceGenerator
*/
CREATE PROCEDURE dbo.uspCourseReferenceGenerator 
	 (@referenceCode VARCHAR(4)
	, @organisationId INT 
	, @prefix VARCHAR(20) NULL
	, @suffix VARCHAR(20) NULL
	, @separator CHAR(1) NULL
	, @venueCode VARCHAR(20) NULL
	, @courseTypeCode VARCHAR(20) NULL
	, @returnMessage VARCHAR(100) OUTPUT)
AS
BEGIN
	
	DECLARE @referenceNumber INT;
	DECLARE @lastRef INT;
	DECLARE @fullReference VARCHAR(100);
	DECLARE @errorMessage VARCHAR(100);


	IF (@referenceCode = 'AN') --Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = CAST(@referenceNumber AS VARCHAR);
		END

		
	IF (@referenceCode = 'ANP') AND (@prefix IS NOT NULL) -- Auto Generated Number with Prefix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @prefix + CAST(@referenceNumber AS VARCHAR);
		END

	ELSE IF (@referenceCode = 'ANP') AND (@prefix IS NULL)
		BEGIN
			SET @errorMessage = 'Prefix is required for reference code ANP';
		END
		

	IF (@referenceCode = 'ANS') AND (@suffix IS NOT NULL)-- Auto Generated Number with Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = CAST(@referenceNumber AS VARCHAR) + @suffix;
		END

	ELSE IF (@referenceCode = 'ANS') AND (@suffix IS NULL)
		BEGIN
			SET @errorMessage = 'Suffix is required for reference code ANS';
		END


	IF (@referenceCode = 'ANPS') AND (@prefix IS NOT NULL) AND (@suffix IS NOT NULL) -- Auto Generated Number with Prefix and Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @prefix + CAST(@referenceNumber AS VARCHAR) + @suffix;
		END
	ELSE IF (@referenceCode = 'ANPS') AND (@prefix IS NULL) OR (@suffix IS NULL)
		BEGIN
			SET @errorMessage = 'Prefix and Suffix are required for reference code ANPS';
		END
	
		
	IF (@referenceCode = 'PSAN') AND (@prefix IS NOT NULL) AND (@suffix IS NOT NULL) AND (@separator IS NOT NULL)-- Auto Generated Number with Prefix and Separator 
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @prefix + ' ' + @separator + ' ' + CAST(@referenceNumber AS VARCHAR) + @suffix;
		END
	ELSE IF (@referenceCode = 'PSAN') AND (@prefix IS NULL) OR (@suffix IS NULL) OR (@separator IS NULL)
		BEGIN
			SET @errorMessage = 'Prefix, Suffix and Seperator are required for reference code PSAN';
		END
	

	IF (@referenceCode = 'ANSP') AND (@suffix IS NOT NULL) AND (@separator IS NOT NULL) -- Auto Generated Number with Separator and Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = CAST(@referenceNumber AS VARCHAR) + ' ' + @separator + ' ' + @suffix;
		END
	ELSE IF (@referenceCode = 'ANSP') AND (@suffix IS NULL) OR (@separator IS NULL)
		BEGIN
			SET @errorMessage = 'Suffix and Separator are required for reference code ANSP';
		END


	IF (@referenceCode = 'VAN') AND (@venueCode IS NOT NULL)-- Venue Code and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @venueCode + CAST(@referenceNumber AS VARCHAR);
		END
	ELSE IF (@referenceCode = 'VAN') AND (@venueCode IS NULL)
		BEGIN
			SET @errorMessage = 'Venue Code is required for reference code VAN';
		END


	IF (@referenceCode = 'VSAN') AND (@venueCode IS NOT NULL) AND (@separator IS NOT NULL) -- Venue Code with Separator and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @venueCode + ' ' + @separator + ' ' + CAST(@referenceNumber as VARCHAR);
		END
	ELSE IF (@referenceCode = 'VSAN') AND (@venueCode IS NULL) OR (@separator IS NULL)
		BEGIN
			SET @errorMessage = 'Venue Code and separator is required for reference code VSAN';
		END


	IF (@referenceCode = 'TAN') AND (@courseTypeCode IS NOT NULL) -- Course Type Code and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @courseTypeCode + CAST(@referenceNumber AS VARCHAR);
		END
	ELSE IF (@referenceCode = 'TAN') AND (@courseTypeCode IS NULL)
		BEGIN
			SET @errorMessage = 'Course Type Code is required for reference code TAN';
		END


	IF (@referenceCode = 'TSAN') AND (@courseTypeCode IS NOT NULL) AND (@separator IS NOT NULL) -- Course Type Code with Separator and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @fullReference = @courseTypeCode + ' ' + @separator + ' ' + CAST(@referenceNumber AS VARCHAR);
		END
	ELSE IF (@referenceCode = 'TSAN') AND (@courseTypeCode IS NULL) OR (@separator IS NULL)
		BEGIN
			SET @errorMessage = 'Course Type Code and Separator are required for reference code TSAN';
		END


	IF (@referenceCode = 'TD') AND (@courseTypeCode IS NOT NULL)-- Course Type code and Formatted Date
		BEGIN
			SET @referenceNumber = CONVERT(VARCHAR,GETDATE(),112);
			SET @fullReference = @courseTypeCode + @referenceNumber;
			INSERT INTO dbo.CourseReferenceNumber(OrganisationId, ReferenceNumber)
			VALUES(@organisationId, @referenceNumber);
		END
	ELSE IF (@referenceCode = 'TD') AND (@courseTypeCode IS NULL)
		BEGIN
			SET @errorMessage = 'Course Type Code and Separator are required for reference code TD';
		END


	IF (@referenceCode = 'TSD') AND (@courseTypeCode IS NOT NULL) AND (@separator IS NOT NULL) --Course Type Code and Separator and Formatted Date
		BEGIN
			SET @referenceNumber = CONVERT(VARCHAR,GETDATE(),112);
			SET @fullReference = @courseTypeCode + ' ' + @separator + ' ' + @referenceNumber;
			INSERT INTO dbo.CourseReferenceNumber(OrganisationId, ReferenceNumber)
			VALUES(@organisationId, @referenceNumber);
		END
	ELSE IF (@referenceCode = 'TSD') AND (@courseTypeCode IS NULL) OR (@separator IS NULL)
		BEGIN
			SET @errorMessage = 'Course Type Code and Separator are required for reference code TSD';
		END

	IF (@errorMessage IS NOT NULL)
		SET @returnMessage = @errorMessage;
	ELSE 
		SET @returnMessage = @fullReference;

	RETURN @returnMessage;

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_23.01_Create_uspCourseReferenceGenerator.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
