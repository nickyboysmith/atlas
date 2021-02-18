/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientCourseBasicData', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientCourseBasicData;
END		
GO

/*
	Create vwClientCourseBasicData
*/
CREATE VIEW vwClientCourseBasicData
AS
	SELECT 
		CORG.OrganisationId							AS OrganisationId
		, O.[Name]									AS OrganisationName
		, C.Id										AS ClientId
		, CDD.DORSAttendanceRef						AS DORSIdentifier
		, C.DisplayName								AS ClientName
		, C.DateCreated								AS ClientCreatedDate
		, LOC.PostCode								AS PostCode
		, CL.LicenceNumber							AS LicenceNumber
		, CP.PhoneNumber							AS PhoneNumber
		, CR.Reference								AS ReferralReference
		, ISNULL(RAC.ReferringAuthorityId, -1)		AS ReferringAuthorityId
		, ISNULL(REFA.[Name], '*UNKNOWN*')			AS ReferringAuthority
		, CO.Id										AS CourseId
		, VWCD.StartDate							AS CourseStartDate
		, CO.Reference								AS CourseReference
		, CT.Id										AS CourseTypeId
		, CT.Title									AS CourseType
		, CT.Code									AS CourseTypeCode
		, CV.VenueId								AS VenueId
		, V.[Title]									AS Venue
		, VR.RegionId								AS RegionId
		, R.[Name]									AS Region
		, CAPPC.PaidSum								AS AmountPaidByClient
	FROM dbo.ClientOrganisation CORG
	INNER JOIN dbo.Organisation O								ON O.Id = CORG.OrganisationId
	INNER JOIN dbo.Client C										ON C.Id = CORG.ClientId
	INNER JOIN dbo.ClientLocation CLOC							ON CLOC.ClientId = CORG.ClientId
	INNER JOIN dbo.[Location] LOC								ON LOC.Id = CLOC.LocationId
	INNER JOIN dbo.ClientLicence CL								ON CL.ClientId = CORG.ClientId
	INNER JOIN vwClientLatestCourseId_SubView CLCI				ON CLCI.ClientId = CORG.ClientId
	INNER JOIN dbo.Course CO									ON CO.Id = CLCI.CourseId
	INNER JOIN dbo.CourseType CT								ON CT.Id = CO.CourseTypeId
	LEFT JOIN [dbo].[DORSSchemeCourseType] DSCT					ON DSCT.CourseTypeId = CT.Id
	INNER JOIN dbo.ClientDORSData CDD							ON CDD.ClientId = CORG.ClientId
																AND CDD.DORSSchemeId = DSCT.DORSSchemeId
	INNER JOIN CourseVenue CV									ON CV.CourseId = CO.Id
	INNER JOIN Venue V											ON V.Id = CV.VenueId
	LEFT JOIN VenueRegion VR									ON VR.VenueId = CV.VenueId
	LEFT JOIN Region R											ON R.Id = VR.RegionId
	INNER JOIN dbo.CourseClient CC								ON CC.CourseId = CLCI.CourseId
																AND CC.ClientId = CORG.ClientId
	INNER JOIN dbo.vwCourseDates_SubView VWCD					ON VWCD.CourseId = CO.Id
	LEFT JOIN vwClientAmountPaidPerCourse_SubView CAPPC			ON CAPPC.CourseId = CLCI.CourseId
																AND CAPPC.ClientId = CORG.ClientId
	LEFT JOIN dbo.ReferringAuthorityClient RAC					ON RAC.ClientId = CORG.ClientId
	LEFT JOIN dbo.ReferringAuthority REFA						ON REFA.Id = RAC.ReferringAuthorityId
	LEFT JOIN dbo.ClientReference CR							ON CR.ClientId = CORG.ClientId
																AND CR.IsPoliceReference = 'True'
	LEFT JOIN dbo.ClientPhone CP								ON CP.ClientId = CORG.ClientId
																AND CP.DefaultNumber = 'True'
	LEFT JOIN dbo.ClientMarkedForDelete CMFD					ON CMFD.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMarkedForArchive CMFA					ON CMFA.ClientId = CORG.ClientId
	LEFT JOIN dbo.CourseClientRemoved CCR						ON CCR.CourseClientId = CC.Id
	WHERE CMFD.Id IS NULL  
	AND CMFA.Id IS NULL 
	AND CCR.Id IS NULL
	;

GO

/*********************************************************************************************************************/
