

SELECT DISTINCT
	CO.Id								AS AtlasCourseId
	, CO.Reference						AS CourseReference
	, DC.DORSCourseIdentifier			AS DORSCourseIdentifier
	, DCD.DORSForceContractIdentifier	AS DORSForceContractIdentifier
	, V.Id								AS AtlasVenueId
	, V.Title							AS VenueName
	, DS.DORSSiteIdentifier				AS DORSSiteIdentifier
	, CD.StartDate						AS CourseStartDateAndTime
	, CD.EndDate						AS CourseEndDateAndTime
	, CT.Title							AS CourseType
	, (CASE WHEN ISNULL(CO.Available, 'False') = 'True'
			THEN 'YES' ELSE 'NO' END)	AS CourseEnabled
	, DSH.[Name]						AS DORSSChemeName
	, DSH.DORSSchemeIdentifier			AS DORSSchemeIdentifier
	, CN.Notes							AS Notes
FROM dbo.Course CO
INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.Courseid = CO.Id
INNER JOIN dbo.CourseType CT					ON CT.Id = CO.CourseTypeId
INNER JOIN dbo.CourseVenue COV					ON COV.CourseId = CO.Id
INNER JOIN dbo.Venue V							ON V.Id = COV.VenueId
LEFT JOIN dbo.DORSSiteVenue DSV					ON DSV.VenueId = V.Id
LEFT JOIN dbo.DORSSite DS						ON DS.Id = DSV.DORSSiteId
LEFT JOIN dbo.DORSSchemeCourseType DSCT			ON DSCT.CourseTypeId = CO.CourseTypeId
LEFT JOIN dbo.DORSScheme DSH					ON DSH.Id = DSCT.DORSSchemeId
LEFT JOIN dbo.vwCourseNotes_SubView CN			ON CN.CourseId = CO.Id
LEFT JOIN dbo.DORSCourse DC						ON DC.CourseId = CO.Id
LEFT JOIN dbo.DORSCourseData DCD				ON DCD.DORSCourseIdentifier = DC.DORSCourseIdentifier
WHERE CO.OrganisationId = 318
AND CD.StartDate > DATEADD(YEAR, -3.5, GETDATE())
ORDER BY CD.StartDate DESC

