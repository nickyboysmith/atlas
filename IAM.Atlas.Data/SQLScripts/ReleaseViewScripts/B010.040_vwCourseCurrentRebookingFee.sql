/*********************************************************************************************************************/
		
		-- vwCourseCurrentRebookingFee List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseCurrentRebookingFee', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseCurrentRebookingFee;
		END		
		GO

		/*
			Create vwCourseCurrentRebookingFee
		*/
		CREATE VIEW vwCourseCurrentRebookingFee
		AS
			SELECT 
					C.OrganisationId				AS OrganisationId
					, C.Id							AS CourseId
					, C.CourseTypeId				AS CourseTypeId
					, C.CourseTypeCategoryId		AS CourseTypeCategoryId
					, CD.StartDate					AS CourseStartDate
					, MIN(RF.RebookingFee)			AS RebookingFee
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD ON CD.Courseid = C.Id
			INNER JOIN vwCourseTypeAndCategoryRebookingActiveConditionNumberAndFee RF ON RF.OrganisationId = C.OrganisationId
																						AND RF.CourseTypeId = C.CourseTypeId
																						AND ISNULL(RF.CourseTypeCategoryId, -1) = ISNULL(C.CourseTypeCategoryId, -1)
			WHERE CD.StartDate BETWEEN RF.BeforeDateMin AND RF.BeforeDate
			GROUP BY C.OrganisationId, C.Id, C.CourseTypeId, C.CourseTypeCategoryId, CD.StartDate
			;


		GO