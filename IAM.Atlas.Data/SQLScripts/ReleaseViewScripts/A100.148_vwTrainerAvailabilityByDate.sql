

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainerAvailabilityByDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAvailabilityByDate;
		END		
		GO
		
		/*** Create vwTrainerAvailabilityByDate

		   NB - This view is used in vwCourseAvailableTrainer 

		 ***/

		 CREATE VIEW dbo.vwTrainerAvailabilityByDate
		 AS 
			SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
				, TAD.[Date]				AS [Date]
			FROM dbo.TrainerAvailabilityDate TAD
			LEFT JOIN dbo.CourseTrainer CT			ON CT.TrainerId = TAD.TrainerId
			LEFT JOIN dbo.CourseDate CD				ON CT.CourseId = CD.CourseId
													AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
			WHERE CD.Id IS NULL
			;
		GO