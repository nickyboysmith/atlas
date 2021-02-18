

		--Course Fees Current

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCourseFeesCurrent', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseFeesCurrent;
		END		
		GO

		/*
			Create vwCourseFeesCurrent
		*/
		CREATE VIEW vwCourseFeesCurrent 
		AS
			SELECT 
				ISNULL(C.OrganisationId,0)					AS OrganisationId
				, ISNULL(C.Id,0)							AS CourseId
				, CFCED.CourseType							AS CourseType
				, CFCED.CourseTypeId						AS CourseTypeId
				, CFCED.CourseTypeCategoryId				AS CourseTypeCategoryId
				, CFCED.CourseTypeCategory					AS CourseTypeCategory
				, C.Reference								AS CourseReference
				, CD.StartDate								AS CourseStartDate
				, CD.EndDate								AS CourseEndDate
				, (CASE WHEN CTCF.Id IS NULL 
						THEN CTF.CourseFee 
						ELSE CTCF.CourseFee END)			AS CourseFee
				, (CASE WHEN CTCF.Id IS NULL 
						THEN CTF.BookingSupplement 
						ELSE CTCF.BookingSupplement END)	AS CourseBookingSupplement
				, (CASE WHEN CTCF.Id IS NULL 
						THEN CTF.PaymentDays 
						ELSE CTCF.PaymentDays END)			AS CoursePaymentDays
				, (CASE WHEN CTCF.Id IS NULL 
						THEN CTF.EffectiveDate 
						ELSE CTCF.EffectiveDate END)		AS CourseFeeEffectiveDate
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
			INNER JOIN vwCourseFeeCurrentEffectiveDate CFCED	ON CFCED.OrganisationId = C.OrganisationId
																AND CFCED.CourseId = C.id
			INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
			LEFT JOIN CourseTypeCategory CTC					ON CTC.Id = C.CourseTypeCategoryId
			LEFT JOIN [dbo].[CourseTypeFee] CTF					ON CTF.OrganisationId = C.OrganisationId
																AND CTF.CourseTypeId = C.CourseTypeId
																AND CTF.EffectiveDate = CFCED.CourseFeeEffectiveDate
																AND CTF.[Disabled] = 'False' 
			LEFT JOIN [dbo].[CourseTypeCategoryFee] CTCF		ON CTCF.OrganisationId = C.OrganisationId
																AND CTCF.CourseTypeId = C.CourseTypeId
																AND CTCF.CourseTypeCategoryId = C.CourseTypeCategoryId
																AND CTCF.EffectiveDate = CFCED.CourseFeeEffectiveDate
																AND CTCF.[Disabled] = 'False' 
			;
		GO


		/*********************************************************************************************************************/
		