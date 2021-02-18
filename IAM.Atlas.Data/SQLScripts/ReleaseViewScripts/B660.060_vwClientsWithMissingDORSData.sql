/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientsWithMissingDORSData', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsWithMissingDORSData;
END		
GO

/*
	Create View vwClientsWithMissingDORSData
*/

CREATE VIEW dbo.vwClientsWithMissingDORSData
AS
		SELECT
		  O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, CLDD.Id						AS ClientDORSDataId
		, CLDD.ClientId					AS ClientId
		, CL.DisplayName				AS ClientName
		, CLL.LicenceNumber				AS ClientLicenceNumber 
		, CLDD.DORSAttendanceStateId	AS DORSAttendanceStateId
		, DAS.[Name]					AS DORSAttendanceState
		, CLDD.DORSAttendanceRef		AS DORSAttendanceRef
		, CLDD.DORSSchemeId				AS DORSSchemeId
		, DS.DORSSchemeIdentifier		AS DORSSchemeIdentifier
		, DS.[Name]						AS DORSSchemeIdentifierName
		, CLDD.DateCreated				AS DateCreated
		, CLDD.DateUpdated				AS DateUpdated
		, CLDD.ExpiryDate				AS ExpiryDate		
		, CAST((CASE WHEN CAST(CLDD.[DateCreated] AS DATE) = CAST(Getdate() AS DATE)
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedToday
		, CAST((CASE WHEN CAST(CLDD.[DateCreated] AS DATE) = CAST((Getdate() - 1) AS DATE)
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedYesterday
		, CAST((CASE WHEN DATEPART(WEEK, CLDD.[DateCreated]) = DATEPART(WEEK, Getdate())
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedThisWeek
		, CAST((CASE WHEN DATEPART(MONTH, CLDD.[DateCreated]) = DATEPART(MONTH, Getdate())
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedThisMonth
		, CAST((CASE WHEN DATEPART(MONTH, CLDD.[DateCreated]) = (DATEPART(MONTH, Getdate()) - 1)
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedLastMonth
		, CAST((CASE WHEN DATEPART(YEAR, CLDD.[DateCreated]) = DATEPART(YEAR, Getdate())
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedThisYear
		, CAST((CASE WHEN DATEPART(YEAR, CLDD.[DateCreated]) < DATEPART(YEAR, Getdate())
					THEN 'True' ELSE 'False' END)
					AS BIT)				AS CreatedBeforeThisYear
	FROM dbo.ClientDORSData CLDD
	INNER JOIN dbo.Client CL						ON CL.Id = CLDD.ClientId
	INNER JOIN dbo.ClientLicence CLL				ON CLL.ClientId = CLDD.ClientId
	INNER JOIN dbo.DORSAttendanceState DAS			ON DAS.Id = CLDD.DORSAttendanceStateId
	INNER JOIN dbo.DORSScheme DS					ON DS.Id = CLDD.DORSSchemeId
	INNER JOIN dbo.ClientOrganisation CO			ON CO.ClientId = CL.Id
	INNER JOIN dbo.Organisation	O					ON CO.OrganisationId = O.Id
	INNER JOIN dbo.CourseClient COCL				ON COCL.ClientId = CLDD.ClientId --Must be Booked onto a Course
	LEFT JOIN dbo.ClientMarkedForDelete CMFD		ON CMFD.ClientId = CL.Id
	LEFT JOIN dbo.ClientDORSData CLDD2				ON CLDD2.ClientId = CLDD.ClientId	--Check for Duplicate Entries ... Se Below
													AND CLDD2.DORSAttendanceRef = CLDD.DORSAttendanceRef
													AND CLDD2.Id != CLDD.Id
	WHERE CLDD.ReferringAuthorityId IS NULL		--Missing Referring Authority
	AND CMFD.Id IS NULL							--Not Marked For Deletion
	AND CLDD.DORSAttendanceStateId IS NOT NULL	--Must Have a Valid Attendance Status
	AND CLDD.DORSAttendanceRef IS NOT NULL		--Must Have a Valid Attendance Reference (Identifier)
	AND ISNULL(CLDD.DateUpdated, '01/01/01') < DATEADD(DAY, -2, GETDATE())	--Should not have been Updated in the Last Two Days. Otherwise we'll be checking the same Client Over and Over Again.
	AND CLDD.DateCreated > DATEADD(MONTH, -3, GETDATE())					--Only Check Clients Created in the Last Three Months
	AND CLDD.IsMysteryShopper = 'False'										--No need to Check Mystery Shoppers
	AND (CLDD2.Id IS NULL OR CLDD2.ReferringAuthorityId IS NULL)			--Check for Duplicate Entries where the Other Entry Already has the Referring Authority set
	;
GO
		
/*********************************************************************************************************************/
