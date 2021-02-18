

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainerAvailability_Subview', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAvailability_Subview;
		END		
		GO
		



		---***NB. THIS VIEW HAS BEEN REPLACED WITH ANOTHER. HENCE WHY THE REMOVE IS IN BUT NOT THE CREATE.











		/*** Create vwTrainerAvailability_Subview

		   NB - This view is used in vwCourseAvailableTrainer 

		 ***/

		-- CREATE VIEW dbo.vwTrainerAvailability_Subview
		-- AS 
		--	SELECT ISNULL(TAD.TrainerId,0)	AS TrainerId
		--		, TAD.[Date]				AS [Date]
		--		, TAD.SessionNumber			AS SessionNumber
		--	FROM dbo.TrainerAvailabilityDate TAD
		--	LEFT JOIN dbo.CourseTrainer CT on TAD.TrainerId = CT.TrainerId
		--	LEFT JOIN dbo.CourseDate CD ON CT.CourseId = CD.CourseId
		--									AND TAD.[Date] BETWEEN CD.DateStart AND CD.DateEnd
		--									AND CD.AssociatedSessionNumber = TAD.SessionNumber
		--	LEFT JOIN dbo.CourseDate CD2 ON CT.CourseId = CD2.CourseId
		--									AND TAD.[Date] BETWEEN CD2.DateStart AND CD2.DateEnd
		--									AND (CD2.AssociatedSessionNumber IS NULL) 
												
		--	WHERE CD.Id IS NULL OR CD2.Id IS NULL

		--GO