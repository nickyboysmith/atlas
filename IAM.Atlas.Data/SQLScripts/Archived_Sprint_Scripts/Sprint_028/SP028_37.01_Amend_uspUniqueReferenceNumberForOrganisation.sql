/*
	SCRIPT: Amend uspUniqueReferenceNumberForOrganisation
	Author: Dan Hough
	Created: 08/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_37.01_Amend_uspUniqueReferenceNumberForOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspUniqueReferenceNumberForOrganisation';
		
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
			IF (SELECT COUNT(ReferenceNumber) FROM dbo.CourseReferenceNumber where OrganisationId = @organisationId) > 0
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
			ELSE
			BEGIN
				INSERT INTO dbo.CourseReferenceNumber (OrganisationId, ReferenceNumber)
				VALUES(@organisationId, 0)
			END
		END
END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP028_37.01_Amend_uspUniqueReferenceNumberForOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
