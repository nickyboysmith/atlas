/*
	SCRIPT: Create stored procedure uspLinkTrainersToSameDORSSchemeAcrossCourseTypes
	Author: Robert Newnham
	Created: 23/12/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_02.01_Create_uspLinkTrainersToSameDORSSchemeAcrossCourseTypes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspLinkTrainersToSameDORSSchemeAcrossCourseTypes';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes;
END		
GO

/*
	Create uspLinkTrainersToSameDORSSchemeAcrossCourseTypes
*/
CREATE PROCEDURE dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes (@courseTypeId INT
																		, @trainerId INT = NULL)
AS
BEGIN

	INSERT INTO TrainerCourseType (TrainerId, CourseTypeId)
	SELECT DISTINCT 
			TCT.TrainerId
			, DSCT.CourseTypeId
	FROM DORSSchemeCourseType DSCT
	INNER JOIN DORSSchemeCourseType DSCT2 ON DSCT2.DORSSchemeId = DSCT.DORSSchemeId
	INNER JOIN TrainerCourseType TCT ON TCT.CourseTypeId = DSCT2.CourseTypeId
	LEFT JOIN TrainerCourseType TCT2 ON TCT2.CourseTypeId = @CourseTypeId
									AND TCT2.TrainerId = (CASE WHEN @TrainerId IS NULL THEN TCT2.TrainerId ELSE @TrainerId END)
	WHERE DSCT.CourseTypeId = @CourseTypeId
	AND DSCT2.CourseTypeId != @CourseTypeId
	AND TCT2.Id IS NULL;

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_02.01_Create_uspLinkTrainersToSameDORSSchemeAcrossCourseTypes.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO