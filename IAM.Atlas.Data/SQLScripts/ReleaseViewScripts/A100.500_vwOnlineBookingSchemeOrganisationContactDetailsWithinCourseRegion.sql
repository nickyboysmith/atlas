
		

-- vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion List
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion;
END		
GO

/*
	Create vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion
*/
CREATE VIEW vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion
AS
	SELECT DISTINCT
		R.Id									AS RegionId
		, R.[Name]								AS RegionName
		, O.Id									AS OrganisationId
		, OD.DisplayName						AS OrganisationName
		, CT.Id									AS CourseTypeId
		, CT.Title								AS CourseTypeTitle
		, DSCT.DORSSchemeId						AS DORSSchemeId
		, DS.DORSSchemeIdentifier				AS DORSSchemeIdentifier
		, DS.[Name]								AS DORSSchemeName
		, (CAST ((CASE WHEN (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0)) > 0
				THEN 'True'
				ELSE 'False'
				END) AS BIT))					AS HasCoursesWithPlaces
		, OC.PhoneNumber						AS OrganisationPhoneNumber
		, (CASE WHEN L.[Address] 
					IN ('(Dummy Address)', 'Dummy Address') 
				THEN ''
				ELSE L.[Address] END)			AS OrganisationAddress
		, (CASE WHEN L.PostCode 
					IN ('(NO PC)', 'NO PC', '(N0 PC)', 'N0 PC') 
				THEN ''
				ELSE L.PostCode END)			AS OrganisationPostCode
		, (CASE WHEN E.[Address] 
					IN ('(dummy@FakeEmailAddress.com)', 'dummy@FakeEmailAddress.com', '(Dummy Address)', 'Dummy Address') 
				THEN ''
				ELSE E.[Address] END)			AS OrganisationEmailAddress
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
	INNER JOIN dbo.OrganisationContact OC				ON OC.OrganisationId = O.Id
	INNER JOIN dbo.[Location] L							ON L.Id = OC.LocationId
	INNER JOIN dbo.Email E								ON E.Id = OC.EmailId
	INNER JOIN dbo.Course C								ON C.OrganisationId = O.Id
	INNER JOIN dbo.CourseVenue CV						ON CV.CourseId = C.Id
	INNER JOIN dbo.Venue V								ON V.Id = CV.VenueId
	INNER JOIN dbo.VenueRegion VR						ON VR.VenueId = CV.VenueId
	INNER JOIN dbo.Region R								ON R.Id = VR.RegionId
	INNER JOIN dbo.vwCourseDates_SubView vCD			ON vCD.Courseid = C.Id
	INNER JOIN dbo.CourseType CT						ON CT.Id = C.CourseTypeId
	INNER JOIN dbo.DORSSchemeCourseType DSCT			ON DSCT.CourseTypeId = C.CourseTypeId
	INNER JOIN dbo.DORSScheme DS						ON DS.Id = DSCT.DORSSchemeId
	LEFT JOIN vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
	LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
	WHERE vCD.StartDate >= GETDATE()
	AND CC.Id IS NULL -- Course not Canceled
	AND (CAST ((CASE WHEN (ISNULL(CV.MaximumPlaces,0)
								- ISNULL(ClientCount.NumberOfClients,0)) > 0
				THEN 'True'
				ELSE 'False'
				END) AS BIT)) = 'True'	--HasCoursesWithPlaces
	;
GO
/*********************************************************************************************************************/
		