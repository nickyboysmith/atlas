/*********************************************************************************************************************/
		
		-- vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee;
		END		
		GO

		/*
			Create vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee
		*/
		CREATE VIEW vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee
		AS
			SELECT
				ISNULL(CTRF.OrganisationId,-1)					AS OrganisationId
				, ISNULL(CTRF.CourseTypeId,-1)					AS CourseTypeId
				, NULL								AS CourseTypeCategoryId
				, CTRF.ConditionNumber				AS ConditionNumber
				, CTRF.EffectiveDate				AS EffectiveDate
				, CTRF.RebookingFee					AS RebookingFee
				, (CASE WHEN CTRF_P.Id IS NULL 
						THEN 0 
						ELSE CTRF_P.DaysBefore END)	AS DaysBeforeMin
				, CTRF.DaysBefore					AS DaysBefore
				, DATEADD(DAY
						, (CASE WHEN CTRF_P.Id IS NULL 
						THEN 0 
						ELSE CTRF_P.DaysBefore END)
						, GETDATE())				AS BeforeDateMin
				, DATEADD(DAY, CTRF.DaysBefore, GETDATE())		AS BeforeDate
			FROM [dbo].[CourseTypeRebookingFee] CTRF
			LEFT JOIN [dbo].[CourseTypeRebookingFee] CTRF_P	ON CTRF_P.OrganisationId = CTRF.OrganisationId
															AND CTRF_P.CourseTypeId = CTRF.CourseTypeId
															AND CTRF_P.EffectiveDate = CTRF.EffectiveDate
															AND ISNULL(CTRF_P.[Disabled], 'False') = 'False'
															AND CTRF_P.ConditionNumber != CTRF.ConditionNumber
															AND CTRF_P.DaysBefore < CTRF.DaysBefore
			INNER JOIN vwCourseTypeRebookingActiveConditionNumber T1 ON T1.OrganisationId = CTRF.OrganisationId
																	AND T1.CourseTypeId = CTRF.CourseTypeId
																	AND T1.ConditionNumber = CTRF.ConditionNumber
																	AND T1.EffectiveDate = CTRF.EffectiveDate
			WHERE ISNULL(CTRF.[Disabled], 'False') = 'False'
			UNION
			SELECT
				ISNULL(CTCRF.OrganisationId,-1)					AS OrganisationId
				, ISNULL(CTCRF.CourseTypeId,-1)					AS CourseTypeId
				, CTCRF.CourseTypeCategoryId			AS CourseTypeCategoryId
				, CTCRF.ConditionNumber					AS ConditionNumber
				, CTCRF.EffectiveDate					AS EffectiveDate
				, CTCRF.RebookingFee					AS RebookingFee
				, (CASE WHEN CTCRF_P.Id IS NULL 
						THEN 0 
						ELSE CTCRF_P.DaysBefore END)	AS DaysBeforeMin
				, CTCRF.DaysBefore						AS DaysBefore
				, DATEADD(DAY
						, (CASE WHEN CTCRF_P.Id IS NULL 
						THEN 0 
						ELSE CTCRF_P.DaysBefore END)
						, GETDATE())				AS BeforeDateMin
				, DATEADD(DAY, CTCRF.DaysBefore, GETDATE())		AS BeforeDate
			FROM [dbo].[CourseTypeCategoryRebookingFee] CTCRF
			LEFT JOIN [dbo].[CourseTypeCategoryRebookingFee] CTCRF_P	ON CTCRF_P.OrganisationId = CTCRF.OrganisationId
																		AND CTCRF_P.CourseTypeId = CTCRF.CourseTypeId
																		AND CTCRF_P.EffectiveDate = CTCRF.EffectiveDate
																		AND ISNULL(CTCRF_P.[Disabled], 'False') = 'False'
																		AND CTCRF_P.ConditionNumber != CTCRF.ConditionNumber
																		AND CTCRF_P.DaysBefore < CTCRF.DaysBefore
			INNER JOIN vwCourseTypeCategoryRebookingActiveConditionNumber T1 ON T1.OrganisationId = CTCRF.OrganisationId
																			AND T1.CourseTypeId = CTCRF.CourseTypeId
																			AND T1.CourseTypeCategoryId = CTCRF.CourseTypeCategoryId
																			AND T1.ConditionNumber = CTCRF.ConditionNumber
																			AND T1.EffectiveDate = CTCRF.EffectiveDate
			WHERE ISNULL(CTCRF.[Disabled], 'False') = 'False'
			;


		GO