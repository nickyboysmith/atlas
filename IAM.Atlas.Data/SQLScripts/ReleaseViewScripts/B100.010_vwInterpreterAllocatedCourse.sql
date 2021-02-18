		-- Course Interpreters allocated courses

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwInterpreterAllocatedCourse', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterAllocatedCourse;
		END		
		GO
		/*
			Create vwInterpreterAllocatedCourse
		*/
		CREATE VIEW dbo.vwInterpreterAllocatedCourse 
		AS

			SELECT 
				I.Id								AS InterpreterId

				, (CASE WHEN LEN(ISNULL(I.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
						ELSE I.[DisplayName] END)	AS InterpreterName

				, I.[GenderId]						AS InterpreterGenderId
				, G.[Name]							AS InterpreterGender
				, ISNULL(C.OrganisationId,0)		AS CourseOrganisationId
				, (CASE WHEN LEN(ISNULL(OD.[DisplayName],'')) <= 0 
						THEN O.[Name]
						ELSE OD.[DisplayName] END)	AS CourseOrganisationName
				, ISNULL(C.Id,0)					AS CourseId
				, CASE WHEN CC.Id IS NULL
					     THEN 'False'
					     ELSE 'True'	
					   END							AS CourseCancelled
				, CType.Title						AS CourseType
				, CType.Id							AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.[Name]						AS CourseTypeCategory
				, C.Reference						AS CourseReference
				, V.Id								AS VenueId
				, V.Title							AS VenueTitle
				, V.[Description]					AS VenueDescription
				, CD.StartDate						AS CourseStartDate
				, CD.EndDate						AS CourseEndDate
			FROM dbo.Interpreter I
			INNER JOIN dbo.Gender G ON G.Id = I.GenderId
			INNER JOIN dbo.CourseInterpreter CI ON CI.InterpreterId = I.Id
			INNER JOIN dbo.Course C ON C.Id = CI.CourseId
			INNER JOIN dbo.CourseType CType ON CType.Id = C.CourseTypeId
			LEFT JOIN dbo.CourseTypeCategory CTC ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN dbo.CancelledCourse CC ON CC.CourseId = C.Id
			LEFT JOIN dbo.CourseVenue CV ON CV.CourseId = C.Id
			LEFT JOIN dbo.Venue V ON CV.VenueId = V.Id
			LEFT JOIN dbo.Organisation O ON O.Id = C.OrganisationId
			LEFT JOIN dbo.OrganisationDisplay OD ON OD.OrganisationId = O.Id
			LEFT JOIN vwCourseDates_SubView CD ON CD.CourseId = C.id
			LEFT JOIN vwCourseClientCount_SubView ClientCount ON ClientCount.Courseid = C.id
			;


			GO
		/*********************************************************************************************************************/