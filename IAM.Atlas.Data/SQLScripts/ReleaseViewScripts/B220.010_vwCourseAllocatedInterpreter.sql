		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseAllocatedInterpreter', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseAllocatedInterpreter;
		END		
		GO
		/*
			Create vwCourseAllocatedInterpreter
		*/
		CREATE VIEW dbo.vwCourseAllocatedInterpreter
		AS
			SELECT 	
				ISNULL(C.OrganisationId,0)												AS OrganisationId
				, ISNULL(C.Id,0)														AS CourseId
				, CType.Title															AS CourseType
				, CType.Id																AS CourseTypeId
				, CTC.Id																AS CourseTypeCategoryId
				, CTC.Name																AS CourseTypeCategory
				, C.Reference															AS CourseReference
				, CD.StartDate															AS CourseStartDate
				, CD.EndDate															AS CourseEndDate
				, CASE WHEN CC.Id IS NULL
					     THEN 'False'
					     ELSE 'True'	
					   END																AS CourseCancelled
				, V.Id																	AS CourseVenueId
				, V.Title																AS CourseVenueName
				, CI.InterpreterId														AS InterpreterId
				, (CASE WHEN LEN(ISNULL(I.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
						ELSE I.[DisplayName] END)										AS InterpreterName
				, I.[GenderId]															AS InterpreterGenderId
				, G.[Name]																AS InterpreterGender
				, CI.BookedForTheory													AS InterpreterBookedForTheory
				, CI.BookedForPractical													AS InterpreterBookedForPractical
				, STUFF(
							(
							SELECT ', ' + L1.EnglishName
							FROM dbo.InterpreterLanguage IL1
							INNER JOIN dbo.[Language] L1 ON L1.Id = IL1.LanguageId
							WHERE IL1.InterpreterId = CI.InterpreterId
							FOR XML PATH('')
							)
							, 1, 2, '')													AS InterpreterLanguageList
			FROM Course C
			INNER JOIN [dbo].[CourseInterpreter] CI			ON CI.[CourseId] = C.Id
			INNER JOIN [dbo].[Interpreter] I				ON I.Id = CI.InterpreterId
			INNER JOIN [dbo].[Gender] G						ON G.Id = I.[GenderId]
			INNER JOIN CourseType CType						ON CType.Id = C.CourseTypeId
			LEFT JOIN CourseTypeCategory CTC				ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CourseVenue CV						ON CV.CourseId = C.Id
			LEFT JOIN Venue V								ON V.Id = CV.VenueId
			LEFT JOIN CancelledCourse CC					ON CC.CourseId = C.Id
			LEFT JOIN vwCourseDates_SubView CD				ON CD.CourseId = C.id
			;
			

		GO

		/*********************************************************************************************************************/

