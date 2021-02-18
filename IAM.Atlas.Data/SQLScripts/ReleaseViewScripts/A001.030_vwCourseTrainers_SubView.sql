
		--Create Sub View vwCourseTrainers_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainers_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainers_SubView;
		END		
		GO

		/*
			Create vwCourseTrainers_SubView
			NB. This view is used within view "vwCourseDetail"
			NB. This view is used within view "vwCourseTrainerConactenatedTrainers_SubView"
		*/
		CREATE VIEW vwCourseTrainers_SubView
		AS
			SELECT 
				CT.[CourseId] AS CourseId
				, CT.[TrainerId] AS TrainerId
				, (CASE WHEN T.[DisplayName] IS NULL OR T.[DisplayName] = '' 
						THEN  + ' ' + T.[FirstName] + ' ' + T.[Surname]
						ELSE T.[DisplayName]
						END) AS TrainerName
			FROM CourseTrainer CT
			INNER JOIN Trainer T ON T.id = CT.[TrainerId];
		GO
		
		/*********************************************************************************************************************/
		