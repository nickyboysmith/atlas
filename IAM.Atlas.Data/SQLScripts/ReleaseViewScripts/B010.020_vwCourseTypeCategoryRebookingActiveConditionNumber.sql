/*********************************************************************************************************************/
		
		-- vwCourseTypeCategoryRebookingActiveConditionNumber List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTypeCategoryRebookingActiveConditionNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTypeCategoryRebookingActiveConditionNumber;
		END		
		GO

		/*
			Create vwCourseTypeCategoryRebookingActiveConditionNumber
		*/
		CREATE VIEW vwCourseTypeCategoryRebookingActiveConditionNumber
		AS
			SELECT 
				ISNULL(OrganisationId,0)					AS OrganisationId
				, ISNULL(CourseTypeId,0)					AS CourseTypeId
				, ISNULL(CourseTypeCategoryId,0)			AS CourseTypeCategoryId
				, ConditionNumber				AS ConditionNumber
				, MAX(EffectiveDate)			AS EffectiveDate
			FROM [dbo].[CourseTypeCategoryRebookingFee] CTCRF1
			WHERE CTCRF1.EffectiveDate <= GETDATE()
			AND ISNULL(CTCRF1.[Disabled], 'False') = 'False'
			GROUP BY OrganisationId, CourseTypeId, CourseTypeCategoryId, ConditionNumber
			;


		GO