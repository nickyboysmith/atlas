
--Course Client Wher Payments are Due

/*
	Drop the View if it already exists
*/		
IF OBJECT_ID('dbo.vwCourseClientPaymentDue', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseClientPaymentDue;
END		
GO

/*
	Create vwCourseClientPaymentDue
*/
CREATE VIEW vwCourseClientPaymentDue
AS
	SELECT			
		ISNULL(C.OrganisationId,0)					AS OrganisationId
		, ISNULL(C.Id,0)							AS CourseId
		, CFC.CourseType							AS CourseType
		, CFC.CourseTypeId							AS CourseTypeId
		, CFC.CourseTypeCategoryId					AS CourseTypeCategoryId
		, CFC.CourseTypeCategory					AS CourseTypeCategory
		, C.Reference								AS CourseReference
		, CD.StartDate								AS CourseStartDate
		, CD.EndDate								AS CourseEndDate
		, CFC.CourseFee								AS CourseFee
		, CFC.CourseBookingSupplement				AS CourseBookingSupplement
		, CFC.CoursePaymentDays						AS CoursePaymentDays
		, CFC.CourseFeeEffectiveDate				AS CourseFeeEffectiveDate
		, CCL.ClientId								AS ClientId
		, (CASE WHEN CE.Id IS NOT NULL
				THEN '**Data Encrypted**'
				ELSE CL.DisplayName END)			AS ClientName
		, ISNULL(CCPS.[NumberOfPayments],0)			AS ClientNumberOfPaymentsMade
		, CCL.TotalPaymentMade						AS ClientTotalPaymentMade
		, CCL.TotalPaymentDue						AS ClientTotalPaymentDue
		, (ISNULL(CCL.TotalPaymentDue,0) - ISNULL(CCL.TotalPaymentMade,0))	AS ClientTotalPaymentOutstanding
		, CCL.[PaymentDueDate]						AS CourseClientPaymentDueDate
		, CAST((CASE WHEN DATEDIFF(DAY, CCL.[PaymentDueDate], GETDATE()) < 7
					AND DATEDIFF(DAY, CCL.[PaymentDueDate], GETDATE()) >= 0
					THEN 'True' ELSE 'False' END) AS BIT)	AS PaymentDueWithinAWeek
		, CAST((CASE WHEN DATEDIFF(DAY, CCL.[PaymentDueDate], GETDATE()) < 3
					AND DATEDIFF(DAY, CCL.[PaymentDueDate], GETDATE()) >= 0
					THEN 'True' ELSE 'False' END) AS BIT)	AS PaymentDueInNextTwoDays
		, CAST((CASE WHEN DATEDIFF(DAY, CCL.[PaymentDueDate], GETDATE()) < 0
				THEN 'True' ELSE 'False' END) AS BIT)	AS PaymentDueDateHasPassed
		, CDD.ExpiryDate							AS ClientDORSExpiryDate
		, CV.VenueId								AS VenueId
		, V.Title									AS VenueTitle
		, V.[Description]							AS VenueDescription
		, L.[Address]								AS VenueAddress
		, L.PostCode								AS VenuePostCode
	FROM Course C
	INNER JOIN dbo.vwCourseDates_SubView CD					ON CD.CourseId = C.id
	INNER JOIN vwCourseFeesCurrent CFC						ON CFC.OrganisationId = C.OrganisationId
															AND CFC.CourseId = C.Id
	INNER JOIN [dbo].[CourseClient] CCL						ON CCL.CourseId = C.Id
	INNER JOIN [dbo].[Client] CL							ON CL.Id = CCL.ClientId
	INNER JOIN CourseVenue CV								ON CV.CourseId = C.Id
	INNER JOIN Venue V										ON CV.VenueId = V.Id
	LEFT JOIN dbo.ClientDORSData CDD						ON CDD.ClientId = CL.Id
	LEFT JOIN [dbo].[VenueAddress] VA						ON VA.VenueId = V.Id
	LEFT JOIN [dbo].[Location] L							ON L.Id = VA.LocationId
	LEFT JOIN [dbo].[CourseClientRemoved] CCR				ON CCR.CourseClientId = CCL.Id
	LEFT JOIN CancelledCourse CC							ON CC.CourseId = C.Id
	LEFT JOIN vwCourseClientPaymentSummary_SubView CCPS		ON CCPS.[CourseId] = CCL.[CourseId]
															AND CCPS.[ClientId] = CCL.[ClientId]	
	LEFT JOIN ClientEncryption CE							ON CE.ClientId = CL.Id
	--WHERE CD.StartDate >= GETDATE()
	WHERE CCR.Id IS NULL
	AND CD.StartDate >= GETDATE()
	AND (ISNULL(CCL.TotalPaymentDue,0) - ISNULL(CCL.TotalPaymentMade,0)) > 0

	;
GO


/*********************************************************************************************************************/


