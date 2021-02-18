
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientDetail;
END		
GO

/*
	Create View vwClientDetail
*/
CREATE VIEW dbo.vwClientDetail 
AS
		SELECT
		O.Id								AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.Title							AS Title
		, C.FirstName						AS FirstName
		, C.Surname							AS Surname
		, C.OtherNames						AS OtherNames
		, C.DisplayName						AS DisplayName
		, C.DateOfBirth						AS DateOfBirth
		, C.DateCreated						AS ClientCreatedDate
		, C.LockedByUserId					AS LockedByUserId
		, LOCK_U.[Name]						AS LockedByUserName
		, C.DateTimeLocked					AS DateTimeLocked
		, LOC.[Address]						AS [Address]
		, LOC.PostCode						AS PostCode
		, CL.LicenceNumber					AS LicenceNumber
		, CL.LicenceExpiryDate				AS LicenceExpiryDate
		, CL.LicencePhotoCardExpiryDate		AS LicencePhotoCardExpiryDate
		, DLT.[Name]						AS DrivingLicenceTypeName
		, E.[Address]						AS EmailAddress
		, CP.PhoneNumber					AS PhoneNumber
		, CR.Reference						AS ReferralReference
		, CO.Id								AS CourseId
		, CO.DefaultStartTime				AS CourseStartTime
		, CO.DefaultEndTime					AS CourseEndTime
		, VWCD.StartDate					AS CourseStartDate
		, VWCD.EndDate						AS CourseEndDate
		, CAST(VWGACS.DateStart2 AS DATE)	AS CourseStartDate2
		, CAST(CAST(VWGACS.DateStart2 AS TIME) AS VARCHAR(5))	AS CourseStartTime2
		, CAST(VWGACE.DateEnd2 AS DATE)		AS CourseEndDate2
		, CAST(CAST(VWGACE.DateEnd2 AS TIME) AS VARCHAR(5))	AS CourseEndTime2
		, CAST(VWGACS.DateStart3 AS DATE)	AS CourseStartDate3
		, CAST(CAST(VWGACS.DateStart3 AS TIME) AS VARCHAR(5))	AS CourseStartTime3
		, CAST(VWGACE.DateEnd3 AS DATE)		AS CourseEndDate3
		, CAST(CAST(VWGACE.DateEnd3 AS TIME) AS VARCHAR(5))	AS CourseEndTime3
		, CO.Reference						AS CourseReference
		, CT.Title							AS CourseType
		, CCFATOB.CourseFee					AS CourseFee
		, CTC.[Name]						AS CourseTypeCategory
		, CDD.ReferringAuthorityId			AS ReferringAuthorityId
		, RA.[Name]							AS ReferringAuthority
		, CC.DateAdded						AS DateBooked
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, VLOC.[Address]					AS VenueAddress
		, VLOC.PostCode						AS VenuePostCode
		, VD.Directions						AS VenueDirection
		, CAPPC.PaidSum						AS AmountPaidByClient
		, CC.TotalPaymentDue				AS TotalPaymentDueByClient
		, CC.PaymentDueDate					AS CoursePaymentDueDate
		, CAST(
			CASE 
				WHEN CMS.ClientId
					IS NOT NULL
				THEN
					'True'
				ELSE
					'False'
				END	AS BIT)								AS IsMysteryShopper
		, CLCI.StillOnCourse							AS StillOnCourse
		, CDD.ExpiryDate								AS DORSExpiryDate
		, VWGCSR.SpecialRequirements					AS SpecialRequirements
		, CASE 
			WHEN 
				CDD.ClientId IS NOT NULL
			THEN 
				CAST(CAST(CAST(DATEADD(DAY, -OSC.DORSClientExpiryDateDaysBeforeCourseBookingAllowed, CDD.ExpiryDate) AS DATE) AS VARCHAR) + ' 23:59:59' AS DATETIME)
			ELSE
				NULL
			END											AS LastDateForCourseBooking
	FROM dbo.ClientOrganisation CORG
	INNER JOIN dbo.Organisation O								ON O.Id = CORG.OrganisationId
	INNER JOIN dbo.OrganisationSelfConfiguration OSC			ON OSC.OrganisationId = O.Id
	INNER JOIN dbo.Client C										ON C.Id = CORG.ClientId
	INNER JOIN dbo.ClientLocation CLOC							ON CLOC.ClientId = CORG.ClientId
	INNER JOIN dbo.[Location] LOC								ON LOC.Id = CLOC.LocationId
	LEFT JOIN dbo.ClientLicence CL								ON CL.ClientId = CORG.ClientId
	LEFT JOIN dbo.vwClientDORSDataLatest CDD					ON CDD.ClientId = CORG.ClientId
	LEFT JOIN dbo.ReferringAuthority RA							ON RA.Id = CDD.ReferringAuthorityId
	LEFT JOIN dbo.[User] LOCK_U									ON LOCK_U.Id = C.LockedByUserId
	LEFT JOIN dbo.DriverLicenceType DLT							ON DLT.Id = CL.DriverLicenceTypeId
	LEFT JOIN vwClientLatestEmailID_SubView CLEI				ON CLEI.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientReference CR							ON CR.ClientId = CORG.ClientId
																AND CR.IsPoliceReference = 'True'
	LEFT JOIN dbo.Email E										ON E.Id = CLEI.EmailId 
	LEFT JOIN dbo.ClientPhone CP								ON CP.ClientId = CORG.ClientId
																AND CP.DefaultNumber = 'True'
	LEFT JOIN vwClientLatestCourseId_SubView CLCI				ON CLCI.ClientId = CORG.ClientId
	LEFT JOIN dbo.Course CO										ON CO.Id = CLCI.CourseId
	LEFT JOIN dbo.CourseTypeCategory CTC						ON CTC.Id = CO.CourseTypeCategoryId 
	LEFT JOIN dbo.CourseType CT									ON CT.Id = CO.CourseTypeId
	LEFT JOIN dbo.CourseClient CC								ON CC.CourseId = CLCI.CourseId
																AND CC.ClientId = CORG.ClientId

	LEFT JOIN dbo.vwCourseClientFeeAtTimeOfBooking CCFATOB		ON CC.CourseId = CCFATOB.CourseId
																AND CC.ClientId = CCFATOB.ClientId

	LEFT JOIN dbo.vwGetAllCourseStartDateAndTimeInOneLine VWGACS	ON CO.Id = VWGACS.CourseId
	LEFT JOIN dbo.vwGetAllCourseEndDateAndTimeInOneLine	VWGACE		ON CO.Id = VWGACE.CourseId
	LEFT JOIN dbo.CourseVenue CV								ON CV.CourseId = CLCI.CourseId
	LEFT JOIN dbo.Venue V										ON CV.VenueId = V.Id 
	LEFT JOIN dbo.VenueAddress VA								ON V.Id = VA.VenueId 
	LEFT JOIN dbo.[Location] VLOC								ON VLOC.Id = VA.LocationId
	LEFT JOIN dbo.VenueDirections VD							ON VD.VenueId = V.Id
	LEFT JOIN dbo.vwCourseDates_SubView VWCD					ON VWCD.CourseId = CO.Id
	LEFT JOIN vwClientAmountPaidPerCourse_SubView CAPPC			ON CAPPC.CourseId = CLCI.CourseId
																AND CAPPC.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMysteryShopper CMS						ON CMS.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMarkedForDelete CMFD					ON CMFD.ClientId = CORG.ClientId
	LEFT JOIN dbo.ClientMarkedForArchive CMFA					ON CMFA.ClientId = CORG.ClientId
	LEFT JOIN dbo.vwGetConcatenatedSpecialRequirements VWGCSR	ON C.Id = VWGCSR.ClientId
	--WHERE CMFD.Id IS NULL  
	--AND CMFA.Id IS NULL 
	;
GO
		
/*********************************************************************************************************************/
