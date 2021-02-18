
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCoursesWithMissingAttendanceVerification', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCoursesWithMissingAttendanceVerification;
		END		
		GO

		/*
			Create View vwCoursesWithMissingAttendanceVerification
		*/
		CREATE VIEW vwCoursesWithMissingAttendanceVerification
		AS	
			SELECT DISTINCT
				O2.Id					AS OrganisationId
				, C.Id					AS CourseId
				, CTY.Id				AS CourseTypeId
				, CTY.Title				AS CourseTypeTitle
				, CD2.StartDate			AS CourseStartDate
				, CD2.EndDate			AS CourseEndDate
			FROM [dbo].[Organisation] O2
			INNER JOIN [dbo].[Course] C			ON C.[OrganisationId] = O2.[Id]
			INNER JOIN [dbo].[CourseType] CTY	ON CTY.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseDate] CD	ON CD.CourseId = C.Id
			INNER JOIN [dbo].[CourseTrainer] CT ON CT.CourseId = C.Id
			INNER JOIN [dbo].[vwCourseDates_SubView] CD2 ON CD2.Courseid = C.Id
			WHERE C.AttendanceCheckRequired = 'True'
			AND C.AttendanceCheckVerified = 'False'
			AND CD.DateEnd <= GetDate() -- Course Which have ended
			AND CD.DateStart > (CAST ('28-Jun-2017' AS DATE)) -- Ignore Due to Migration
			AND NOT EXISTS (SELECT [Id] 
							FROM [dbo].[CourseDateClientAttendance] CDCA
							WHERE CDCA.CourseDateId = CD.[Id]
							AND CDCA.[CourseId] = C.[Id]
							AND CDCA.TrainerId = CT.Id)
			;
			/*****************************************************************************************************************/
		GO
		
		/*********************************************************************************************************************/
		