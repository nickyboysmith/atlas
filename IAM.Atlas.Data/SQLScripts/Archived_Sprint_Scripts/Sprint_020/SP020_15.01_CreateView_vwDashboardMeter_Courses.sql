/*
	SCRIPT: Create a Dashboard Meter View for Courses
	Author: Robert Newnham
	Created: 08/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_15.01_CreateView_vwDashboardMeter_Courses.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_Courses';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_Courses', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_Courses;
	END		
	GO

	/*
		Create View vwDashboardMeter_Courses
	*/
	CREATE VIEW vwDashboardMeter_Courses AS	
		SELECT 
				O.[Id] As OrganisationId
				, O.[Name] AS OrganisationName
				, (CASE WHEN CourseAttendance.CoursesWithoutAttendance IS NULL
						THEN 0
						ELSE CourseAttendance.CoursesWithoutAttendance
						END) AS CoursesWithoutAttendance
				, (CASE WHEN UBC.TotalNumberUnpaid IS NULL 
						THEN 0 ELSE UBC.TotalNumberUnpaid END) AS NumberOfUnpaidCourses
				, (CASE WHEN UBC.TotalAmountUnpaid IS NULL 
						THEN 0 ELSE UBC.TotalAmountUnpaid END) AS TotalAmountUnpaid	
		FROM [dbo].[Organisation] O
		LEFT JOIN (SELECT O2.[Id] 
						, COUNT(*) AS CoursesWithoutAttendance
					FROM [dbo].[Organisation] O2
					INNER JOIN [dbo].[Course] C ON C.[OrganisationId] = O2.[Id]
					WHERE NOT EXISTS (SELECT [Id] 
										FROM [dbo].[CourseDateClientAttendance] CDCA
										WHERE CDCA.[CourseId] = C.[Id])
					GROUP BY O2.[Id]
					) CourseAttendance ON CourseAttendance.[Id] = O.[Id]
		LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.[Id]
		;

		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_15.01_CreateView_vwDashboardMeter_Courses.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO


