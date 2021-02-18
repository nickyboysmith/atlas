
-- DORS Courses With Places for OnlineBooking
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDORSCoursesWithPlacesForOnlineBooking', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDORSCoursesWithPlacesForOnlineBooking;
END		
GO

/*
	Create vwDORSCoursesWithPlacesForOnlineBooking
*/
CREATE VIEW vwDORSCoursesWithPlacesForOnlineBooking
AS	
	SELECT
		ISNULL(C.OrganisationId,0)			AS OrganisationId
		, O.[Name]							AS OrganisationName
		, ISNULL(C.Id,0)					AS CourseId
		, C.Reference						AS CourseReference
		, ISNULL(C.HasInterpreter,'False')	AS HasInterpreter
		, CD.StartDate						AS StartDate
		, CD.EndDate						AS EndDate
		, LEFT(DATENAME(dw, CD.StartDate), 3) 
			+ ', ' + CONVERT(VARCHAR(9), CD.StartDate, 6)
			+ ' ' + CONVERT(VARCHAR(5), CD.StartDate, 14)	AS StartDateFormated
		, LEFT(DATENAME(dw, CD.EndDate), 3) 
			+ ', ' + CONVERT(VARCHAR(9), CD.EndDate, 6)
			+ ' ' + CONVERT(VARCHAR(5), CD.EndDate, 14)		AS EndDateFormated
		, CT.Title							AS CourseType
		, CT.Id								AS CourseTypeId
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, R.Id								AS RegionId
		, R.[Name]							AS RegionName
		, ClientCount.NumberOfClients		AS NumberofClientsonCourse
		, (CASE WHEN CV.MaximumPlaces - ClientCount.NumberOfClients <= 0
				THEN 0
				ELSE CV.MaximumPlaces - ClientCount.NumberOfClients
				END)													AS PlacesRemaining
		, (CASE WHEN CV.MaximumPlaces
						- CV.ReservedPlaces
						- ClientCount.NumberOfClients <= 0
				THEN 0
				ELSE CV.MaximumPlaces
						- CV.ReservedPlaces
						- ClientCount.NumberOfClients
				END)													AS OnlinePlacesRemaining
		, CAST((CASE WHEN CV.MaximumPlaces - ClientCount.NumberOfClients < 0 
					THEN 'True'
					ELSE 'False'
					END) AS BIT)										AS CourseOverBooked
		, ISNULL(CCRF.RebookingFee,0)									AS CourseRebookingFee
	FROM Course C
	INNER JOIN Organisation O							ON O.Id = C.OrganisationId
	INNER JOIN OrganisationSelfConfiguration OSC		ON OSC.OrganisationId = C.OrganisationId
	INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
	INNER JOIN vwCourseDates_SubView CD					ON CD.CourseId = C.id
														AND CD.StartDate >= (GETDATE() + OSC.[OnlineBookingCutOffDaysBeforeCourse])
	INNER JOIN [dbo].[DORSSchemeCourseType] DSCT		ON DSCT.CourseTypeId = CT.Id
	INNER JOIN CourseVenue CV							ON CV.CourseId = C.Id
	INNER JOIN Venue V									ON V.Id = CV.VenueId
	INNER JOIN VenueRegion VR							ON VR.VenueId = CV.VenueId
	INNER JOIN Region R									ON R.Id = VR.RegionId
	INNER JOIN vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
	LEFT JOIN vwCourseCurrentRebookingFee CCRF			ON CCRF.OrganisationId = C.OrganisationId
														AND CCRF.CourseId = C.Id
	LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
	WHERE CC.Id IS NULL -- Course not Cancelled
	AND (CV.MaximumPlaces - CV.ReservedPlaces - ClientCount.NumberOfClients) > 0
	AND C.Available = 'True'
	;
GO
/*********************************************************************************************************************/
		