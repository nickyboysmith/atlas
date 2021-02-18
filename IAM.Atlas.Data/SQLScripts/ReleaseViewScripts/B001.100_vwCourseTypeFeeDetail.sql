/*********************************************************************************************************************/
		
		-- vwCourseTypeFeeDetail
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTypeFeeDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTypeFeeDetail;
		END		
		GO

		/*
			Create vwCourseTypeFeeDetail
		*/
		CREATE VIEW [dbo].[vwCourseTypeFeeDetail]
		AS
			SELECT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, CT.Id						AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, NULL						AS CourseTypeCategoryId
				, NULL						AS CourseTypeCategoryTitle
				, CTF.Id					AS CourseTypeFeeId
				, NULL						AS CourseTypeCategoryFeeId
				, CTF.EffectiveDate			AS EffectiveDate
				, CTF.CourseFee				AS CourseFee
				, CTF.BookingSupplement		AS BookingSupplement
				, CTF.PaymentDays			AS PaymentDays
			FROM Organisation O
			INNER JOIN OrganisationDisplay OD			ON OD.OrganisationId = O.Id
			INNER JOIN CourseType CT					ON CT.OrganisationId = O.Id
			INNER JOIN CourseTypeFee CTF				ON CTF.CourseTypeId = CT.Id
			WHERE CTF.[Disabled] = 'False'
			UNION ALL
			SELECT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, CT.Id						AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, CTC.Id					AS CourseTypeCategoryId
				, CTC.[Name]				AS CourseTypeCategoryName
				, NULL						AS CourseTypeFeeId
				, CTCF.Id					AS CourseTypeCategoryFeeId
				, CTCF.EffectiveDate		AS EffectiveDate
				, CTCF.CourseFee			AS CourseFee
				, CTCF.BookingSupplement	AS BookingSupplement
				, CTCF.PaymentDays			AS PaymentDays
			FROM Organisation O
			INNER JOIN OrganisationDisplay OD			ON OD.OrganisationId = O.Id
			INNER JOIN CourseType CT					ON CT.OrganisationId = O.Id
			INNER JOIN CourseTypeCategory CTC			ON CTC.CourseTypeId = CT.Id
			INNER JOIN CourseTypeCategoryFee CTCF		ON CTCF.CourseTypeId = CT.Id
														AND CTCF.CourseTypeCategoryId = CTC.Id
			WHERE CTCF.[Disabled] = 'False'
			;
			

GO


