
		
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCoursesWithMissingAttendance', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCoursesWithMissingAttendance;
		END		
		GO

		/*
			Create View vwCoursesWithMissingAttendance
		*/
		CREATE VIEW vwCoursesWithMissingAttendance
		AS	
			SELECT DISTINCT
				O2.Id					AS OrganisationId
				, C.Id					AS CourseId
				, CTY.Id				AS CourseTypeId
				, CTY.Title				AS CourseTypeTitle
				, CD.DateStart			AS CourseStartDate
				, CD.DateEnd			AS CourseEndDate
				, CT.TrainerId			AS TrainerId
				, T.DisplayName			AS TrainerName
				, TCD.TrainerMobileNumber	AS TrainerMobileNumber
				, TCD.TrainerHomeNumber		AS TrainerHomeNumber
				, TCD.TrainerWorkNumber		AS TrainerWorkNumber
				, TCD.TrainerEmail			AS TrainerEmail
			FROM [dbo].[Organisation] O2
			INNER JOIN [dbo].[Course] C			ON C.[OrganisationId] = O2.[Id]
			INNER JOIN [dbo].[CourseType] CTY	ON CTY.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseDate] CD	ON CD.CourseId = C.Id
			INNER JOIN [dbo].[CourseTrainer] CT ON CT.CourseId = C.Id
			INNER JOIN [dbo].[Trainer] T		ON T.Id = CT.TrainerId
			LEFT JOIN [dbo].vwTrainerContactDetail_SubView TCD ON TCD.TrainerId = CT.TrainerId
			WHERE C.AttendanceCheckRequired = 'True'
			AND C.AttendanceCheckVerified = 'False'
			AND CT.AttendanceCheckRequired = 'True'
			AND CD.DateEnd <= GetDate()
			AND NOT EXISTS (SELECT [Id] 
							FROM [dbo].[CourseDateClientAttendance] CDCA
							WHERE CDCA.CourseDateId = CD.[Id]
							AND CDCA.[CourseId] = C.[Id]
							AND CDCA.TrainerId = CT.Id)
			;
			/*****************************************************************************************************************/
		GO
		
		/*********************************************************************************************************************/
		