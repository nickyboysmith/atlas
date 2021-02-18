
-- Courses With Places Available for Booking
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCoursesWithPlaces', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCoursesWithPlaces;
END		
GO
/*
	Create vwCoursesWithPlaces
*/
CREATE VIEW vwCoursesWithPlaces
AS	
	SELECT
		ISNULL(C.OrganisationId,0)			AS OrganisationId
		, O.[Name]							AS OrganisationName
		, ISNULL(C.Id,0)					AS CourseId
		, C.Reference						AS CourseReference
		, ISNULL(C.HasInterpreter,'False')	AS HasInterpreter
		, CD.StartDate						AS StartDate
		, CD.EndDate						AS EndDate
		, CS.SessionNumber					AS CourseSessionNumber
		, CS.SessionTitle					AS CourseSessionTitle
		, CT.Title							AS CourseType
		, CT.Id								AS CourseTypeId
		, CTC.[Name]						AS CourseTypeCategory
		, CTC.Id							AS CourseTypeCategoryId
		, C.LastBookingDate					AS CourseLastBookingDate
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, ISNULL(R.Id, -1)					AS RegionId
		--, ISNULL(R.[Name], '*UNKNOWN*')		AS RegionName
		--, CAST((CASE WHEN DSCT.Id IS NULL
		--		THEN 'False'
		--		ELSE 'True'
		--		END) AS BIT)				AS DORSCourse
		, C.DORSCourse						AS DORSCourse
		, ClientCount.NumberOfClients		AS NumberofClientsonCourse
		, CV.ReservedPlaces					AS CourseReservedPlaces
		, CV.MaximumPlaces					AS CourseMaximumPlaces
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
		, CLAES.CourseLocked											AS CourseLocked
		, CLAES.CourseProfileUneditable									AS CourseProfileUneditable
	FROM Course C
	INNER JOIN Organisation O							ON O.Id = C.OrganisationId
	--INNER JOIN OrganisationSelfConfiguration OSC		ON OSC.OrganisationId = C.OrganisationId
	INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
	LEFT JOIN CourseTypeCategory CTC					ON CTC.Id = C.CourseTypeCategoryId
	INNER JOIN vwCourseDates_SubView CD					ON CD.CourseId = C.id
	LEFT JOIN vwCourseSession CS						ON CS.CourseId = C.id
	INNER JOIN CourseVenue CV							ON CV.CourseId = C.Id
	INNER JOIN Venue V									ON V.Id = CV.VenueId
	LEFT JOIN VenueRegion VR							ON VR.VenueId = CV.VenueId
	LEFT JOIN Region R									ON R.Id = VR.RegionId
	--LEFT JOIN [dbo].[DORSSchemeCourseType] DSCT			ON DSCT.CourseTypeId = CT.Id
	LEFT JOIN vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
	LEFT JOIN vwCourseCurrentRebookingFee CCRF			ON CCRF.OrganisationId = C.OrganisationId
														AND CCRF.CourseId = C.Id
	LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id	
	WHERE CD.StartDate >= GETDATE()
	AND C.Available = 'True'
	AND CC.Id IS NULL -- Course not Canceled
	AND CLAES.CourseLocked = 'False' -- Course Not Locked
	AND (ISNULL(CV.MaximumPlaces,0)
		- ISNULL(ClientCount.NumberOfClients,0)) > 0
	;
GO
/*********************************************************************************************************************/
		