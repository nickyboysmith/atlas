
		--Create Sub View vwTrainerDatesUnavailble_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerDatesUnavailble_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerDatesUnavailble_SubView;
		END		
		GO

		/*
			Create vwTrainerDatesUnavailble_SubView
			NB. This view is used within view "vwCourseAvailableTrainers"
		*/
		CREATE VIEW vwTrainerDatesUnavailble_SubView
		AS
			SELECT TDU.[TrainerId]
				, (CASE WHEN TDU.[AllDay] = 'True' 
						THEN  DATEADD(day, DATEDIFF(DAY, 0, TDU.[StartDate]), 0)
						ELSE TDU.[StartTime] END) AS StartDateTime
				, (CASE WHEN TDU.[AllDay] = 'True' 
						THEN  DATEADD(millisecond, -2, DATEADD(day, DATEDIFF(DAY, 0, TDU.[StartDate])+1, 0))
						ELSE TDU.[EndTime] END) AS EndDateTime
			FROM [dbo].[TrainerDatesUnavailable] TDU
			WHERE TDU.[Removed] != 'True'
			--AND TDU.[StartDate] >= GETDATE()
			UNION
			SELECT CT.[TrainerId]
				, CD.StartDate AS StartDateTime
				, CD.EndDate AS EndDateTime
			FROM [dbo].[CourseTrainer] CT 
			INNER JOIN vwCourseDates_SubView CD ON CD.CourseId = CT.CourseId
			--WHERE CD.[StartDate] >= GETDATE()
			;
		GO

		/*********************************************************************************************************************/
		