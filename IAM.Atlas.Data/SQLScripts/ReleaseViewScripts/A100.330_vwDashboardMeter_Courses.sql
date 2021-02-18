
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
		CREATE VIEW vwDashboardMeter_Courses 
		AS
			SELECT
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, CoursesWithoutAttendance
				, CoursesWithoutAttendanceVerfication
				, NumberOfUnpaidCourses
				, TotalAmountUnpaid
			FROM [dbo].[DashboardMeterData_Course] C
			;
			--SELECT 
			--		O.[Id] As OrganisationId
			--		, O.[Name] AS OrganisationName
			--		, ISNULL(CourseAttendance.CoursesWithoutAttendance,0) AS CoursesWithoutAttendance
			--		, ISNULL(CourseAttendanceVerfication.CoursesWithoutAttendanceVerfication,0) AS CoursesWithoutAttendanceVerfication
			--		, ISNULL(UBC.TotalNumberUnpaid,0) AS NumberOfUnpaidCourses
			--		, ISNULL(UBC.TotalAmountUnpaid,0) AS TotalAmountUnpaid	
			--FROM [dbo].[Organisation] O
			--LEFT JOIN (SELECT O2.Id
			--				, COUNT(*) AS CoursesWithoutAttendance
			--			FROM [dbo].[Organisation] O2
			--			INNER JOIN [dbo].[Course] C ON C.[OrganisationId] = O2.[Id]
			--			INNER JOIN [dbo].[CourseDate] CD ON CD.CourseId = C.Id
			--			INNER JOIN [dbo].[CourseTrainer] CT ON CT.CourseId = C.Id
			--			WHERE C.AttendanceCheckRequired = 'True'
			--			AND C.AttendanceCheckVerified = 'False'
			--			AND CT.AttendanceCheckRequired = 'True'
			--			AND CD.DateEnd <= GetDate()
			--			AND NOT EXISTS (SELECT [Id] 
			--							FROM [dbo].[CourseDateClientAttendance] CDCA
			--							WHERE CDCA.[CourseId] = C.[Id]
			--							AND CDCA.TrainerId = CT.Id)
			--			GROUP BY O2.[Id]
			--			) CourseAttendance ON CourseAttendance.[Id] = O.[Id]
			--LEFT JOIN (SELECT O3.Id
			--				, COUNT(DISTINCT C3.Id) AS CoursesWithoutAttendanceVerfication
			--			FROM [dbo].[Organisation] O3
			--			INNER JOIN [dbo].[Course] C3 ON C3.[OrganisationId] = O3.[Id]
			--			INNER JOIN [dbo].[CourseDate] CD3 ON CD3.CourseId = C3.Id
			--			INNER JOIN [dbo].[CourseTrainer] CT3 ON CT3.CourseId = C3.Id
			--			WHERE C3.AttendanceCheckRequired = 'True'
			--			AND C3.AttendanceCheckVerified = 'False'
			--			AND CD3.DateEnd <= GetDate()
			--			GROUP BY O3.[Id]
			--			) CourseAttendanceVerfication ON CourseAttendanceVerfication.[Id] = O.[Id]
			--LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.[Id]
			--;

			/*****************************************************************************************************************/
		GO
	
		/*********************************************************************************************************************/
		