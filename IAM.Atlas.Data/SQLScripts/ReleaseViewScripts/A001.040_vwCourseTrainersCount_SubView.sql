
		--Create Sub View vwCourseTrainersCount_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainersCount_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainersCount_SubView;
		END		
		GO

		/*
			Create vwCourseTrainersCount_SubView
			NB. This view is used within view "vwCourseDetail"
			NB. This view is used within view "vwCourseTrainerConactenatedTrainers_SubView"
		*/
		CREATE VIEW vwCourseTrainersCount_SubView
		AS
			SELECT 
				CT.[CourseId] AS CourseId
				, COUNT(*) As NumberOfTrainers
			FROM CourseTrainer CT
			GROUP BY CT.[CourseId]
		GO
		
		/*********************************************************************************************************************/
		