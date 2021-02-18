/*
	SCRIPT: Amend Stored Procedure to generate a course reference
	Author: Dan Hough
	Created: 06/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_01.01_Amend_uspCourseReferenceGenerator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored Procedure to generate a course reference';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the proc if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseReferenceGenerator', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseReferenceGenerator;
END		
GO

/*
	Create uspCourseReferenceGenerator
*/
CREATE PROCEDURE [dbo].[uspCourseReferenceGenerator] 
	 (@referenceCode VARCHAR(4)
	, @organisationId INT 
	, @prefix VARCHAR(20) NULL
	, @suffix VARCHAR(20) NULL
	, @separator VARCHAR(4) NULL
	, @venueCode VARCHAR(20) NULL
	, @courseTypeCode VARCHAR(20) NULL
	, @returnMessage VARCHAR(100) OUTPUT)
AS
BEGIN
	
	DECLARE @referenceNumber INT,
			 @lastRef INT;
	
	SET @separator = (CASE WHEN @separator IS NULL THEN '' ELSE ' ' + @separator + ' ' END);

	IF (@referenceCode = 'AN') --Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = CAST(@referenceNumber AS VARCHAR);
		END

		
	ELSE IF (@referenceCode = 'ANP') AND (@prefix IS NOT NULL) -- Auto Generated Number with Prefix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @prefix + CAST(@referenceNumber AS VARCHAR);
		END
		

	ELSE IF (@referenceCode = 'ANS') AND (@suffix IS NOT NULL)-- Auto Generated Number with Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = CAST(@referenceNumber AS VARCHAR) + @suffix;
		END


	ELSE IF (@referenceCode = 'ANPS') AND (@prefix IS NOT NULL) AND (@suffix IS NOT NULL) -- Auto Generated Number with Prefix and Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @prefix + CAST(@referenceNumber AS VARCHAR) + @suffix;
		END
	
		
	ELSE IF (@referenceCode = 'PSAN') AND (@prefix IS NOT NULL) AND (@suffix IS NOT NULL)-- Auto Generated Number with Prefix and Separator 
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @prefix + @separator + CAST(@referenceNumber AS VARCHAR) + @suffix;
		END
	

	ELSE IF (@referenceCode = 'ANSP') AND (@suffix IS NOT NULL) -- Auto Generated Number with Separator and Suffix
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = CAST(@referenceNumber AS VARCHAR) + @separator + @suffix;
		END


	ELSE IF (@referenceCode = 'VAN') AND (@venueCode IS NOT NULL)-- Venue Code and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @venueCode + CAST(@referenceNumber AS VARCHAR);
		END


	ELSE IF (@referenceCode = 'VSAN') AND (@venueCode IS NOT NULL) -- Venue Code with Separator and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @venueCode + @separator + CAST(@referenceNumber as VARCHAR);
		END


	ELSE IF (@referenceCode = 'TAN') AND (@courseTypeCode IS NOT NULL) -- Course Type Code and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @courseTypeCode + CAST(@referenceNumber AS VARCHAR);
		END


	ELSE IF (@referenceCode = 'TSAN') AND (@courseTypeCode IS NOT NULL) -- Course Type Code with Separator and Auto Generated Number
		BEGIN
			EXEC dbo.uspUniqueReferenceNumberForOrganisation @organisationId, @referenceNumber OUTPUT;
			SET @returnMessage = @courseTypeCode + @separator + CAST(@referenceNumber AS VARCHAR);
		END


	ELSE IF (@referenceCode = 'TD') AND (@courseTypeCode IS NOT NULL)-- Course Type code and Formatted Date
		BEGIN
			SET @referenceNumber = CONVERT(VARCHAR,GETDATE(),112);
			SET @returnMessage = @courseTypeCode + CAST(@referenceNumber AS VARCHAR);
			INSERT INTO dbo.CourseReferenceNumber(OrganisationId, ReferenceNumber)
			VALUES(@organisationId, @referenceNumber);
		END


	ELSE IF (@referenceCode = 'TSD') AND (@courseTypeCode IS NOT NULL)--Course Type Code and Separator and Formatted Date
		BEGIN
			SET @referenceNumber = CONVERT(VARCHAR,GETDATE(),112);
			SET @returnMessage = @courseTypeCode + @separator + CAST(@referenceNumber AS VARCHAR);
			INSERT INTO dbo.CourseReferenceNumber(OrganisationId, ReferenceNumber)
			VALUES(@organisationId, @referenceNumber);
		END
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP036_01.01_Amend_uspCourseReferenceGenerator.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
