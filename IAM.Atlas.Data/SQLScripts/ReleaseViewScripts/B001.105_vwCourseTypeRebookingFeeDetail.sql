/*********************************************************************************************************************/
		
		-- vwCourseTypeRebookingFeeDetail List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTypeRebookingFeeDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTypeRebookingFeeDetail;
		END		
		GO

		/*
			Create vwCourseTypeRebookingFeeDetail
		*/
		CREATE VIEW vwCourseTypeRebookingFeeDetail
		AS
			SELECT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, CT.Id						AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, NULL						AS CourseTypeCategoryId
				, NULL						AS CourseTypeCategoryTitle
				, CTRF.Id					AS CourseTypeRebookingFeeId
				, NULL						AS CourseTypeCategoryRebookingFeeId
				, CTRF.ConditionNumber		AS ConditionNumber
				, CTRF.EffectiveDate		AS EffectiveDate
				, CTRF.DaysBefore			AS DaysBefore
				, CTRF.RebookingFee			AS RebookingFee
			FROM Organisation O
			INNER JOIN OrganisationDisplay OD			ON OD.OrganisationId = O.Id
			INNER JOIN CourseType CT					ON CT.OrganisationId = O.Id
			INNER JOIN CourseTypeRebookingFee CTRF		ON CTRF.CourseTypeId = CT.Id
			WHERE ISNULL(CTRF.[Disabled], 'False') = 'False'
			UNION
			SELECT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, CT.Id						AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, CTC.Id					AS CourseTypeCategoryId
				, CTC.[Name]				AS CourseTypeCategoryName
				, NULL						AS CourseTypeRebookingFeeId
				, CTCRF.Id					AS CourseTypeCategoryRebookingFeeId
				, CTCRF.ConditionNumber		AS ConditionNumber
				, CTCRF.EffectiveDate		AS EffectiveDate
				, CTCRF.DaysBefore			AS DaysBefore
				, CTCRF.RebookingFee		AS RebookingFee
			FROM Organisation O
			INNER JOIN OrganisationDisplay OD					ON OD.OrganisationId = O.Id
			INNER JOIN CourseType CT							ON CT.OrganisationId = O.Id
			INNER JOIN CourseTypeCategory CTC					ON CTC.CourseTypeId = CT.Id
			INNER JOIN CourseTypeCategoryRebookingFee CTCRF		ON CTCRF.CourseTypeId = CT.Id
																AND CTCRF.CourseTypeCategoryId = CTC.Id
			WHERE ISNULL(CTCRF.[Disabled], 'False') = 'False'
			;


		GO