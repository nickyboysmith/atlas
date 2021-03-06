/*
	SCRIPT: Create a stored procedure to remove stencil courses
	Author: Dan Hough
	Created: 28/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_41.01_Amend_SP_uspRemoveCoursesFromCourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend stored procedure to remove stencil courses';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRemoveCoursesFromCourseStencil', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRemoveCoursesFromCourseStencil;
END		
GO

	/*
		Create uspRemoveCoursesFromCourseStencil
	*/

	CREATE PROCEDURE dbo.uspRemoveCoursesFromCourseStencil @CourseStencilId INT
			
	AS
	BEGIN
		SELECT csc.CourseId
		INTO #CSTemp
		FROM dbo.CourseStencil cs
		INNER JOIN dbo.CourseStencilCourse csc ON cs.Id = csc.CourseStencilId
		LEFT OUTER JOIN dbo.CourseClient cc ON csc.CourseId = cc.CourseId
		WHERE cs.id = @CourseStencilId
					  AND cc.ClientId IS NULL
					  AND cs.CreateCourses = 'True'
					  AND cs.RemoveCourses = 'True'
					  AND cs.[Disabled] = 'False'
					  AND cs.[DateCoursesRemoved] IS NULL
		
		IF (SELECT COUNT(*) FROM #CSTemp) > 0
		BEGIN
			DELETE FROM dbo.CourseStencilCourse
			WHERE CourseId IN (SELECT CourseId FROM #CSTemp)

			DELETE FROM dbo.CourseDocument
			WHERE CourseId IN (SELECT CourseId FROM #CSTemp)

			DELETE FROM dbo.CourseDate
			WHERE CourseId IN (SELECT CourseId FROM #CSTemp)

			DELETE FROM dbo.DORSCourse
			WHERE CourseId IN (SELECT CourseId FROM #CSTemp)

			DELETE FROM dbo.Course
			WHERE Id IN (SELECT CourseId FROM #CSTemp)

		END

		DROP TABLE #CSTemp

	END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_41.01_Amend_SP_uspRemoveCoursesFromCourseStencil.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
