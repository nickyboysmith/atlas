
		-- View Trainer Booked Dates and Sessions
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwTrainerBookedDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerBookedDate;
		END		
		GO

		/*
			Create vwTrainerBookedDate
		*/
		CREATE VIEW vwTrainerBookedDate
		AS
			SELECT CT.TrainerId						AS TrainerId
				, CT.CourseId						AS CourseId
				, MIN(CAST(CD.DateStart AS DATE))	AS CourseStartDate
				, MAX(CAST(CD.DateEnd AS DATE))		AS CourseEndDate
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 1 
							THEN 1 ELSE 0 END)		AS Session1Booked
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 2
							THEN 1 ELSE 0 END)		AS Session2Booked
				, MAX(CASE WHEN CD.AssociatedSessionNumber IS NULL
							OR CD.AssociatedSessionNumber = 3
							THEN 1 ELSE 0 END)		AS Session3Booked
					
			FROM CourseTrainer CT
			LEFT JOIN CourseDate CD		ON CD.CourseId = CT.CourseId
			GROUP BY CT.TrainerId, CT.CourseId
			;
			
		GO
		/*********************************************************************************************************************/
		