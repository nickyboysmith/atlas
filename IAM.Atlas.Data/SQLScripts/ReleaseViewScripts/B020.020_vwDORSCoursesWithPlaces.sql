
		-- DORS Courses With Places Available for Booking
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwDORSCoursesWithPlaces', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwDORSCoursesWithPlaces;
		END		
		GO
		/*
			Create vwDORSCoursesWithPlaces
		*/
		CREATE VIEW vwDORSCoursesWithPlaces
		AS	
			SELECT
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, O.[Name]							AS OrganisationName
				, ISNULL(C.Id,0)					AS CourseId
				, C.Reference						AS CourseReference
				, ISNULL(C.HasInterpreter,'False')	AS HasInterpreter
				, CD.StartDate						AS StartDate
				, CD.EndDate						AS EndDate
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, V.Id								AS VenueId
				, V.Title							AS VenueName
				, R.Id								AS RegionId
				, R.[Name]							AS RegionName
				, ClientCount.NumberOfClients		AS NumberofClientsonCourse
				, (CASE WHEN (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0)) <= 0
						THEN 0
						ELSE (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0))
						END)													AS PlacesRemaining
				, (CASE WHEN (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(CV.ReservedPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0)) <= 0
						THEN 0
						ELSE (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(CV.ReservedPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0))
						END)													AS OnlinePlacesRemaining
				, CAST((CASE WHEN (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0)) < 0 
							THEN 'True'
							ELSE 'False'
							END) AS BIT)										AS CourseOverBooked
				, ISNULL(CCRF.RebookingFee,0)									AS CourseRebookingFee
			FROM Course C
			INNER JOIN Organisation O							ON O.Id = C.OrganisationId
			INNER JOIN OrganisationSelfConfiguration OSC		ON OSC.OrganisationId = C.OrganisationId
			INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
			INNER JOIN vwCourseDates_SubView CD					ON CD.CourseId = C.id
			INNER JOIN [dbo].[DORSSchemeCourseType] DSCT		ON DSCT.CourseTypeId = CT.Id
			INNER JOIN CourseVenue CV							ON CV.CourseId = C.Id
			INNER JOIN Venue V									ON V.Id = CV.VenueId
			INNER JOIN VenueRegion VR							ON VR.VenueId = CV.VenueId
			INNER JOIN Region R									ON R.Id = VR.RegionId
			LEFT JOIN vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
			LEFT JOIN vwCourseCurrentRebookingFee CCRF			ON CCRF.OrganisationId = C.OrganisationId
																AND CCRF.CourseId = C.Id
			LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
			WHERE CD.StartDate >= (GETDATE() + OSC.[OnlineBookingCutOffDaysBeforeCourse])
			AND CC.Id IS NULL -- Course not Canceled
			AND (ISNULL(CV.MaximumPlaces,0)
				- ISNULL(ClientCount.NumberOfClients,0)) > 0
			;
		GO
		/*********************************************************************************************************************/
		