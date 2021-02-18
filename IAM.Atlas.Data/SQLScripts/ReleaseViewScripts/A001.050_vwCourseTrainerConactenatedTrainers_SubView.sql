
		--Create Sub View vwCourseTrainerConactenatedTrainers_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainerConactenatedTrainers_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainerConactenatedTrainers_SubView;
		END		
		GO

		/*
			Create vwCourseTrainerConactenatedTrainers_SubView
			NB. This view is used within view "vwCourseDetail"
		*/
		CREATE VIEW vwCourseTrainerConactenatedTrainers_SubView
		AS
			SELECT DISTINCT CT.CourseId 
				, STUFF(
							(
							SELECT ',' + CT1.TrainerName
							FROM vwCourseTrainers_SubView CT1
							WHERE CT1.CourseId = CT.CourseId
							FOR XML PATH('')
							)
							, 1, 1, '') AS Trainers
				, CTC.NumberOfTrainers
			FROM vwCourseTrainers_SubView CT
			INNER JOIN vwCourseTrainersCount_SubView CTC ON CTC.CourseId = CT.CourseId;
		GO
		
		/*********************************************************************************************************************/
		