
		--Course Trainer Simple List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainerCount_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainerCount_SubView;
		END		
		GO
		/*
			Create vwCourseTrainerCount_SubView
		*/
		CREATE VIEW vwCourseTrainerCount_SubView 
		AS		
			SELECT 
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, ISNULL(CTR.CourseId,0)			AS CourseId
				, TrainerList.NumberOfTrainers		AS NumberOfTrainersBookedOnCourse
				, ISNULL(CTR.TrainerId,0)			AS TrainerId
				, ROW_NUMBER() OVER(PARTITION BY  C.OrganisationId, CTR.CourseId, TrainerList.NumberOfTrainers
									ORDER BY C.OrganisationId, CTR.CourseId, CTR.[DateCreated], TrainerList.NumberOfTrainers) AS TrainerNumber
			FROM [dbo].[CourseTrainer] CTR
			INNER JOIN [dbo].[Course] C ON C.Id = CTR.CourseId
			INNER JOIN dbo.vwCourseTrainerConactenatedTrainers_SubView TrainerList ON TrainerList.CourseId = C.id			
			;
		GO
		/*********************************************************************************************************************/
		