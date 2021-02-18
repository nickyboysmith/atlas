
/*
	Drop the Procedure if it already exists
*/	
IF OBJECT_ID('dbo.vwClientDetailMinimal', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientDetailMinimal;
END		
GO

/*
	Create View vwClientDetailMinimal
*/
CREATE VIEW dbo.vwClientDetailMinimal 
AS
		SELECT
		O.Id								AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS DisplayName
		, C.DateCreated						AS ClientCreatedDate
		, LOC.PostCode						AS PostCode
		, CL.LicenceNumber					AS LicenceNumber
		, CP.PhoneNumber					AS PhoneNumber
		, CR.Reference						AS ReferralReference
		, CO.Id								AS CourseId
		, VWCD.StartDate					AS CourseStartDate
		, CO.Reference						AS CourseReference
		, CT.Title							AS CourseType
		, CAPPC.PaidSum						AS AmountPaidByClient
		, CLCI.StillOnCourse				AS StillOnCourse
		, CASE 
			WHEN 
				CDD.ClientId IS NOT NULL
			THEN 
				CAST(CAST(CAST(DATEADD(DAY, -OSC.DORSClientExpiryDateDaysBeforeCourseBookingAllowed, CDD.ExpiryDate) AS DATE) AS VARCHAR) + ' 23:59:59' AS DATETIME)
			ELSE
				NULL
			END								AS LastDateForCourseBooking
	FROM dbo.ClientOrganisation CORG
	INNER JOIN dbo.Organisation O								ON O.Id = CORG.OrganisationId
	INNER JOIN dbo.OrganisationSelfConfiguration OSC			ON OSC.OrganisationId = O.Id
	INNER JOIN dbo.Client C										ON C.Id = CORG.ClientId
	INNER JOIN dbo.ClientLocation CLOC							ON CLOC.ClientId = CORG.ClientId
	INNER JOIN dbo.[Location] LOC								ON LOC.Id = CLOC.LocationId
	LEFT JOIN dbo.ClientLicence CL								ON CL.ClientId = CORG.ClientId
	LEFT JOIN dbo.vwClientDORSDataLatest CDD					ON CDD.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientReference CR							ON CR.ClientId = CORG.ClientId
																	AND CR.IsPoliceReference = 'True'
	LEFT JOIN dbo.ClientPhone CP								ON CP.ClientId = CORG.ClientId
																	AND CP.DefaultNumber = 'True'
	LEFT JOIN vwClientLatestCourseId_SubView CLCI				ON CLCI.ClientId = CORG.ClientId
	LEFT JOIN dbo.Course CO										ON CO.Id = CLCI.CourseId
	LEFT JOIN dbo.CourseType CT									ON CT.Id = CO.CourseTypeId
	LEFT JOIN CourseClientRemoved CCR							ON CCR.ClientId = CORG.ClientId
																	AND CCR.CourseId = CLCI.CourseId
	LEFT JOIN dbo.CourseClient CC								ON CC.CourseId = CLCI.CourseId
																	AND CC.ClientId = CORG.ClientId
																	AND CC.Id != CCR.CourseClientId
	LEFT JOIN dbo.vwCourseDates_SubView VWCD					ON VWCD.CourseId = CO.Id
	LEFT JOIN vwClientAmountPaidPerCourse_SubView CAPPC			ON CAPPC.CourseId = CLCI.CourseId
																	AND CAPPC.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMarkedForDelete CMFD					ON CMFD.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMarkedForArchive CMFA					ON CMFA.ClientId = CORG.ClientId
	WHERE CMFD.Id IS NULL  
	AND CMFA.Id IS NULL 
	;

GO
		
/*********************************************************************************************************************/
		
