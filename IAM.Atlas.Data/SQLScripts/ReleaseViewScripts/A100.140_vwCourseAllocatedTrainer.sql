
		-- Data View of Trainers Booked onto Courses
		

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCourseAllocatedTrainer', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseAllocatedTrainer;
		END		
		GO
		
		/**
		 * Create vwCourseAllocatedTrainer
		 */
		CREATE VIEW [dbo].[vwCourseAllocatedTrainer] 
		AS 
			SELECT 	
				ISNULL(C.OrganisationId,0)												AS OrganisationId
				, ISNULL(C.Id,0)														AS CourseId
				, CType.Title															AS CourseType
				, CType.Id																AS CourseTypeId
				, CTC.Id																AS CourseTypeCategoryId
				, CTC.Name																AS CourseTypeCategory
				, C.Reference															AS CourseReference
				, CD.StartDate															AS CourseStartDate
				, CD.EndDate															AS CourseEndDate
				, CASE WHEN CC.Id IS NULL
					     THEN 'False'
					     ELSE 'True'	
					   END																AS CourseCancelled
				, V.Id																	AS CourseVenueId
				, V.Title																AS CourseVenueName
				, CLAES.CourseLocked													AS CourseLocked
				, CLAES.CourseProfileUneditable											AS CourseProfileUneditable
				, CT.TrainerId															AS TrainerId
				, (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
						ELSE T.[DisplayName] END)										AS TrainerName
				, T.[GenderId]															AS TrainerGenderId
				, G.[Name]																AS TrainerGender
				, U.[LoginId]															AS TrainerLoginId
				, ISNULL(TV.[DistanceHomeToVenueInMiles], -1)							AS TrainerDistanceToVenueInMiles
				, ISNULL(CONVERT(INT, ROUND(TV.[DistanceHomeToVenueInMiles], 0)), -1)	AS TrainerDistanceToVenueInMilesRounded
				, ISNULL(TV.[TrainerExcluded], 'False')									AS TrainerExcludedFromVenue
				, CT.BookedForTheory													AS TrainerBookedForTheory
				, CT.BookedForPractical													AS TrainerBookedForPractical
			FROM Course C
			INNER JOIN [dbo].[CourseTrainer] CT					ON CT.[CourseId] = C.Id
			INNER JOIN [dbo].[Trainer] T						ON T.Id = CT.TrainerId
			INNER JOIN [dbo].[Gender] G							ON G.Id = T.[GenderId]
			INNER JOIN CourseType CType							ON CType.Id = C.CourseTypeId
			INNER JOIN dbo.TrainerCourseType TCT				ON TCT.[CourseTypeId] = C.[CourseTypeId]
																AND TCT.TrainerId = T.Id
			LEFT JOIN CourseVenue CV							ON CV.CourseId = C.Id
			LEFT JOIN Venue V									ON V.Id = CV.VenueId
			LEFT JOIN TrainerVenue TV							ON TV.TrainerId = T.Id
																AND TV.VenueId = V.Id
			LEFT JOIN CourseTypeCategory CTC					ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
			LEFT JOIN [dbo].[User] U							ON U.Id = T.[UserId]
			LEFT JOIN vwCourseDates_SubView CD					ON CD.CourseId = C.id
			LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id	
			;
			

		GO


		/*********************************************************************************************************************/
		