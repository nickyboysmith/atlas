
		--Trainers within Courses

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainersWithinCourse', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainersWithinCourse;
		END		
		GO
		/*
			Create vwTrainersWithinCourse
		*/
		CREATE VIEW vwTrainersWithinCourse 
		AS
			SELECT c.OrganisationId			AS OrganisationId
				, cd.StartDate			AS CourseStartDate
				, ct.Title				AS CourseType
				, ctc.Name				AS CourseCategory
				, c.Reference			AS CourseReference
				, t.Id					AS TrainerId
				, t.DisplayName			AS TrainerName
				, ctr.DateCreated		AS TrainerAllocatedDate
				, CLAES.CourseLocked				AS CourseLocked
				, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
					
			FROM CourseTrainer ctr
			INNER JOIN Course c									ON c.Id = ctr.CourseId
			INNER JOIN Trainer t								ON t.Id = ctr.TrainerId				  
			INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
			INNER JOIN CourseType ct							ON ct.Id = c.CourseTypeId
			LEFT JOIN CourseTypeCategory ctc					ON ctc.Id = c.CourseTypeCategoryId
			LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id	
			;
		GO
		/*********************************************************************************************************************/
