

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseRegisterData', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseRegisterData;
END		
GO

/*
	Create vwCourseRegisterData
*/
CREATE VIEW vwCourseRegisterData
AS
	SELECT
		C.OrganisationId										AS OrganisationId
		, O.[Name]												AS OrganisationName
		, C.Id													AS CourseId
		, DATENAME(WEEKDAY, CD.StartDate) 
			+ ' ' + CONVERT(VARCHAR, CD.StartDate, 106)			AS CourseDate
		, V.Title
			+ (CASE WHEN LEN(PD.PostTown) > 0 
					AND NOT(V.Title LIKE '%' + PD.PostTown + '%') --Include Postal Town if not already in the Name
				THEN ', ' + PD.PostTown ELSE '' END)			AS CourseVenueNameAddress
		, dbo.udfGetCourseNotes_ExternalViewing(C.Id)			AS CourseRegisterNotes
		, CC.ClientId											AS ClientId
		, CL.FirstName											AS CourseClientForename
		, CL.Surname											AS CourseClientSurname
		, CLL.LicenceNumber										AS ClientLicenceNumber
		, CLR.Reference											AS ClientPoliceReference
		, '' + CAST(C.OrganisationId AS VARCHAR) 
				+ '~' + CAST(C.Id AS VARCHAR) 
				+ '~' + CONVERT(VARCHAR, CD.StartDate, 120)
				+ '~' + ISNULL(CL.Surname,'')
				+ '~' + ISNULL(CL.FirstName,'')
				+ '~' + ISNULL(CL.OtherNames,'')
																AS DataSortColumn
		, CSR.SpecialRequirements								AS ClientSpecialRequirements
	FROM Course C
	INNER JOIN dbo.Organisation O			ON O.Id = C.OrganisationId
	INNER JOIN vwCourseDates_SubView CD		ON CD.Courseid = C.Id
	INNER JOIN CourseVenue CV				ON CV.CourseId = C.Id
	INNER JOIN Venue V						ON V.Id = CV.VenueId
	INNER JOIN VenueAddress VA				ON VA.VenueId = CV.VenueId
	INNER JOIN [Location] L					ON L.Id = VA.LocationId
	LEFT JOIN PostalDistrict PD				ON PD.PostcodeDistrict = REPLACE(L.PostCode, RIGHT(L.PostCode, 3), '') -- Find the Postal Town
	LEFT JOIN CourseClient CC				ON CC.CourseId = C.Id
	LEFT JOIN CourseClientRemoved CCR		ON CC.Id = CCR.CourseClientId
												AND CC.ClientId = CCR.ClientId
	LEFT JOIN Client CL						ON CL.Id = CC.ClientId
	LEFT JOIN ClientLicence CLL				ON CL.Id = CLL.ClientId
	LEFT JOIN ClientReference CLR			ON CL.Id = CLR.ClientId
	LEFT JOIN vwClientSpecialRequirementsOnOneLine CSR	ON CL.Id = CSR.ClientId 
	WHERE (CD.StartDate >= DATEADD(MONTH, -1, GETDATE())) 
		AND (CCR.CourseClientId IS NULL)
		AND ISNULL(CLR.IsPoliceReference, 'True') = 'True';

GO