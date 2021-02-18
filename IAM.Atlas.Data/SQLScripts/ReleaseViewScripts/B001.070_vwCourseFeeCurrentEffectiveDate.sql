
		--Course Fees Current Effective Date

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCourseFeeCurrentEffectiveDate', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseFeeCurrentEffectiveDate;
		END		
		GO

		/*
			Create vwCourseFeeCurrentEffectiveDate
		*/
		CREATE VIEW vwCourseFeeCurrentEffectiveDate
		AS
			SELECT 
				ISNULL(C.OrganisationId,0)					AS OrganisationId
				, ISNULL(C.Id,0)							AS CourseId
				, CT.Title									AS CourseType
				, CT.Id										AS CourseTypeId
				, CTC.Id									AS CourseTypeCategoryId
				, CTC.Name									AS CourseTypeCategory
				, MAX((CASE WHEN CTCF.Id IS NULL 
						THEN CTF.EffectiveDate 
						ELSE CTCF.EffectiveDate END))		AS CourseFeeEffectiveDate
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.CourseId = C.id
			INNER JOIN CourseType CT						ON CT.Id = C.CourseTypeId
			LEFT JOIN CourseTypeCategory CTC				ON CTC.Id = C.CourseTypeCategoryId
			LEFT JOIN [dbo].[CourseTypeFee] CTF				ON CTF.OrganisationId = C.OrganisationId
															AND CTF.CourseTypeId = C.CourseTypeId
															AND CTF.EffectiveDate < GETDATE()
															AND CTF.[Disabled] = 'False' 
			LEFT JOIN [dbo].[CourseTypeCategoryFee] CTCF	ON CTCF.OrganisationId = C.OrganisationId
															AND CTCF.CourseTypeId = C.CourseTypeId
															AND CTCF.CourseTypeCategoryId = C.CourseTypeCategoryId
															AND CTCF.EffectiveDate < GETDATE()
															AND CTCF.[Disabled] = 'False' 
			GROUP BY 
				C.OrganisationId
				, C.Id
				, CT.Title
				, CT.Id
				, CTC.Id
				, CTC.Name
			;
		GO



		/*********************************************************************************************************************/
		