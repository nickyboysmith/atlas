
		
		
		-- Data View of Course Allocated to Trainers
		
		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwTrainerAllocatedCourse', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwTrainerAllocatedCourse;
		END		
		GO

		/**
		 * Create vwTrainerAllocatedCourse
		 */
		CREATE VIEW [dbo].[vwTrainerAllocatedCourse] 
		AS 
			SELECT 
				T.Id								AS TrainerId
				, (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
						ELSE T.[DisplayName] END)	AS TrainerName
				, T.[GenderId]						AS GenderId
				, G.[Name]							AS Gender
				, U.[LoginId]						AS LoginId
				, ISNULL(C.OrganisationId,0)		AS CourseOrganisationId
				, (CASE WHEN LEN(ISNULL(OD.[DisplayName],'')) <= 0 
						THEN O.[Name]
						ELSE OD.[DisplayName] END)	AS CourseOrganisationName
				, ISNULL(C.Id,0)					AS CourseId
				, CASE WHEN CC.Id IS NULL
					     THEN 'False'
					     ELSE 'True'	
					   END							AS CourseCancelled
				, CType.Title						AS CourseType
				, CType.Id							AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.Name							AS CourseTypeCategory
				, C.Reference						AS CourseReference
				, V.Id								AS VenueId
				, V.Title							AS VenueTitle
				, V.[Description]					AS VenueDescription
				, CD.StartDate						AS StartDate
				, CD.EndDate						AS EndDate
				, CV.MaximumPlaces					AS MaximumVenuePlaces
				, CV.ReservedPlaces					AS ReservedVenuePlaces
				, (ISNULL(CV.MaximumPlaces,0)
					- ISNULL(ClientCount.NumberOfClients,0))					AS PlacesRemaining
				, ISNULL(ClientCount.NumberOfClients,0)							AS NumberOfBookedClients
				, CAST(ISNULL(CT.[AttendanceCheckRequired], 'True') AS BIT)		AS AttendanceCheckRequired
				, CT.[AttendanceLastUpdated]									AS AttendanceLastUpdated
				, CAST(ISNULL(C.[AttendanceCheckVerified], 'False') AS BIT)		AS AttendanceCheckVerified
			FROM [dbo].[Trainer] T
			INNER JOIN [dbo].[Gender] G ON G.Id = T.[GenderId]
			INNER JOIN [dbo].[CourseTrainer] CT ON CT.[TrainerId] = T.Id
			INNER JOIN [dbo].[Course] C ON C.Id = CT.[CourseId]
			INNER JOIN CourseType CType ON CType.Id = C.CourseTypeId
			LEFT JOIN CourseTypeCategory CTC ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CancelledCourse CC ON CC.CourseId = C.Id
			LEFT JOIN CourseVenue CV ON CV.CourseId = C.Id
			LEFT JOIN Venue V ON CV.VenueId = V.Id
			LEFT JOIN [dbo].[Organisation] O ON O.Id = C.OrganisationId
			LEFT JOIN [dbo].[OrganisationDisplay] OD ON OD.[OrganisationId] = O.Id
			LEFT JOIN [dbo].[User] U ON U.Id = T.[UserId]
			LEFT JOIN vwCourseDates_SubView CD ON CD.CourseId = C.id
			LEFT JOIN vwCourseClientCount_SubView ClientCount ON ClientCount.Courseid = C.id			
			;
			

		GO

		/*********************************************************************************************************************/
		