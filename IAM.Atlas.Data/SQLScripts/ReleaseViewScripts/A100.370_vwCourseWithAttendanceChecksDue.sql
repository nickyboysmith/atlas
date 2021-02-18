
		IF OBJECT_ID('dbo.vwCourseWithAttendanceChecksDue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseWithAttendanceChecksDue;
		END		
		GO
		

		/*
			Create View vwCourseWithAttendanceChecksDue
		*/
		CREATE VIEW dbo.vwCourseWithAttendanceChecksDue
		AS
			SELECT DISTINCT
				O.[Id]						AS OrganisationId
				, O.[Name]					AS OrganisationName
				, C.Id						AS CourseId
				, C.CourseTypeId			AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, CD.DateStart				AS CourseStarteDate
				, CD.DateEnd				AS CourseEndDate
				, T.DisplayName				AS TrainerName
			FROM [dbo].[CourseDate] CD
			INNER JOIN [dbo].[Course] C ON C.Id = CD.CourseId
			INNER JOIN [dbo].[CourseTrainer] CTR ON CTR.CourseId = CD.CourseId
			INNER JOIN [dbo].[Trainer] T ON T.Id = CTR.TrainerId
			INNER JOIN [dbo].[CourseType] CT ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[Organisation] O ON O.Id = C.OrganisationId
			LEFT JOIN [dbo].[CourseDateClientAttendance] CDCA ON CDCA.CourseDateId = CD.Id
															AND CDCA.TrainerId = CTR.TrainerId
			WHERE CD.DateEnd <= GetDate()
			AND C.AttendanceCheckRequired = 'True'
			AND CTR.AttendanceCheckRequired = 'True'
			AND CDCA.Id IS NULL
			;
		GO
		
		/*********************************************************************************************************************/
		