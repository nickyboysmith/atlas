/*
	SCRIPT: Create a Stored Procedure to generate a course reference
	Author: Dan Hough
	Created: 14/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_22.01_Create_uspUniqueReferenceNumberForOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to generate a unique reference number for organisation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.uspUniqueReferenceNumberForOrganisation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUniqueReferenceNumberForOrganisation;
END		
GO

/*
	Create uspUniqueReferenceNumberForOrganisation
*/
CREATE PROCEDURE uspUniqueReferenceNumberForOrganisation (@organisationId INT, @referenceNumber INT OUTPUT)
AS
BEGIN
	DECLARE @success BIT = 'False';

	WHILE (@success = 'False')
		BEGIN
			INSERT INTO dbo.CourseReferenceNumber (OrganisationId, ReferenceNumber)
			SELECT organisationId, MAX(ReferenceNumber) + 1
			FROM dbo.CourseReferenceNumber
			WHERE OrganisationId = @organisationId
			GROUP BY OrganisationId;

			IF (SCOPE_IDENTITY() IS NOT NULL)
			BEGIN
				SET @success = 'True';
				SELECT @referenceNumber = ReferenceNumber
				FROM dbo.CourseReferenceNumber
				WHERE Id = SCOPE_IDENTITY();
			END
		END
END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_22.01_Create_uspUniqueReferenceNumberForOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
