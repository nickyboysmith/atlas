/*
	SCRIPT: Create Stored procedure uspGetCourseDORSTrainerIdentifiersAndLicenceTypes
	Author: Paul Tuck
	Created: 23/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_03.01_CreateSP_uspGetCourseDORSTrainerIdentifiersAndLicenceTypes';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspGetCourseDORSTrainerIdentifiersAndLicenceTypes';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspGetCourseDORSTrainerIdentifiersAndLicenceTypes', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspGetCourseDORSTrainerIdentifiersAndLicenceTypes];
END		
GO
	/*
		Create [uspGetCourseDORSTrainerIdentifiersAndLicenceTypes]
	*/
	
	CREATE PROCEDURE [dbo].[uspGetCourseDORSTrainerIdentifiersAndLicenceTypes](@courseId INT)
	AS
	BEGIN

		SELECT DISTINCT dtl.DORSTrainerIdentifier, dtlt.identifier as DORSTrainerLicenceTypeIdentifier
		FROM course c
		INNER JOIN coursetrainer ct ON c.id = ct.courseid
		INNER JOIN dorstrainer dt ON dt.trainerid = ct.trainerid
		INNER JOIN dorstrainerLicence dtl ON dtl.[DORSTrainerIdentifier] = dt.DORSTrainerIdentifier
		INNER JOIN [DORSTrainerLicenceType] dtlt ON dtlt.name = dtl.[DORSTrainerLicenceTypeName]
		INNER JOIN [dbo].[DORSScheme] ds ON ds.[DORSSchemeIdentifier] = dtl.[DORSSchemeIdentifier]
		INNER JOIN [dbo].[DORSSchemeCourseType] dsct ON dsct.coursetypeid = c.coursetypeid
														AND dsct.[DORSSchemeId] = ds.id
		WHERE ct.courseId = @courseid
		AND (
				(ct.bookedfortheory = 'true' AND dtlt.name = 'Theory') 
				OR
				(ct.bookedforpractical = 'true' AND dtlt.name = 'Practical')
			);

	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_03.01_CreateSP_uspGetCourseDORSTrainerIdentifiersAndLicenceTypes';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
