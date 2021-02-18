/*********************************************************************************************************************/
		
		-- vwCourseTypeRebookingActiveConditionNumber List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTypeRebookingActiveConditionNumber', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTypeRebookingActiveConditionNumber;
		END		
		GO

		/*
			Create vwCourseTypeRebookingActiveConditionNumber
		*/
		CREATE VIEW vwCourseTypeRebookingActiveConditionNumber
		AS
			SELECT 
				ISNULL(OrganisationId,0)					AS OrganisationId
				, ISNULL(CourseTypeId,0)					AS CourseTypeId
				, ISNULL(ConditionNumber,0)				AS ConditionNumber
				, MAX(EffectiveDate)			AS EffectiveDate
			FROM [dbo].[CourseTypeRebookingFee] CTRF1
			WHERE CTRF1.EffectiveDate <= GETDATE()
			AND ISNULL(CTRF1.[Disabled], 'False') = 'False'
			GROUP BY OrganisationId, CourseTypeId, ConditionNumber
			;


		GO