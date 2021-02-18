
		--Course Client Fees And Payment Summary

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCourseClientFeesAndPaymentSummary', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientFeesAndPaymentSummary;
		END		
		GO

		/*
			Create vwCourseClientFeesAndPaymentSummary
		*/
		CREATE VIEW vwCourseClientFeesAndPaymentSummary
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
				, ISNULL(CCPS.[TotalPaymentAmount],0)		AS ClientTotalPaymentMade
				, (CASE WHEN ISNULL(CCL.TotalPaymentDue, -1) <= 0
						THEN CFC.CourseFee
						ELSE CCL.TotalPaymentDue END)		AS ClientTotalPaymentDue
				, CDD.ExpiryDate							AS ClientDORSExpiryDate
				, CV.VenueId								AS VenueId
				, V.Title									AS VenueTitle
				, V.[Description]							AS VenueDescription
				, L.[Address]								AS VenueAddress
				, L.PostCode								AS VenuePostCode
				, VR.RegionId								As RegionId
				, CDD.Id									As ClientDORSDataId
				, DC.Id										AS DORSCourseId
				, [dbo].[udfCourseTodaysRebookingFee](C.Id)	AS CourseRebookingFee
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD					ON CD.CourseId = C.id
			INNER JOIN vwCourseFeesCurrent CFC						ON CFC.OrganisationId = C.OrganisationId
																	AND CFC.CourseId = C.Id
			INNER JOIN [dbo].[CourseClient] CCL						ON CCL.CourseId = C.Id
			INNER JOIN [dbo].[Client] CL							ON CL.Id = CCL.ClientId
			INNER JOIN CourseVenue CV								ON CV.CourseId = C.Id
			INNER JOIN Venue V										ON CV.VenueId = V.Id
			INNER JOIN VenueRegion VR								ON VR.VenueId = V.Id
			LEFT JOIN dbo.ClientDORSData CDD						ON CDD.ClientId = CL.Id
			LEFT JOIN DORSCourse DC									ON DC.CourseId = C.Id
			LEFT JOIN [dbo].[VenueAddress] VA						ON VA.VenueId = V.Id
			LEFT JOIN [dbo].[Location] L							ON L.Id = VA.LocationId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR				ON CCR.CourseClientId = CCL.Id
			LEFT JOIN CancelledCourse CC							ON CC.CourseId = C.Id
			LEFT JOIN vwCourseClientPaymentSummary_SubView CCPS		ON CCPS.[CourseId] = CCL.[CourseId]
																	AND CCPS.[ClientId] = CCL.[ClientId]	
			LEFT JOIN ClientEncryption CE							ON CE.ClientId = CL.Id
			--WHERE CD.StartDate >= GETDATE()
			WHERE CCR.Id IS NULL			
			;
		GO


/*********************************************************************************************************************/


