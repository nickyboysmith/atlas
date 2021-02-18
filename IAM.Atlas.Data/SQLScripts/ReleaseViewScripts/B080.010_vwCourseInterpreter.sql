		-- Course Interpreters

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseInterpreter', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseInterpreter;
		END		
		GO
		/*
			Create vwCourseInterpreter
		*/
		CREATE VIEW vwCourseInterpreter 
		AS
			SELECT c.OrganisationId
					, c.Id AS CourseId
					, c.CourseTypeId
					, c.CourseTypeCategoryId
					, CTC.[Name] AS CourseTypeCategory
					, C.Reference AS CourseReference
					, CD.StartDate AS CourseStartDate
					, CD.EndDate AS CourseEndDate
					, ISNULL(ClientCount.NumberOfClients,0) AS NumberOfBookedClients
					, ISNULL(TrainerCount.NumberOfTrainers,0) AS NumberOfTrainersBookedOnCourse
					, CV.VenueId
					, V.Title AS VenueName
					, C.Available AS CourseAvailable
					, CONVERT(BIT, (CASE WHEN CC.Id IS NULL 
												THEN 'False'
												ELSE 'True'
												END)) AS CancelledCourse
					, I.Id AS InterpreterId
					, (CASE WHEN LEN(ISNULL(I.[DisplayName],'')) <= 0 
									THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
									ELSE I.[DisplayName] 
									END) AS InterpreterName
					, G.Id AS InterpreterGenderId
					, G.[Name] AS InterpreterGender
					, ('Interpreter: ' 
						+ CAST(CICS.InterpreterNumber AS CHAR(1)) 
						+ ' of '
						+ CAST(CIT.NumberOfInterpreters AS CHAR(1))) AS InterpreterOneOf
					, CI.BookedForTheory AS InterpreterForTheory
					, CI.BookedForPractical AS InterpreterForPractical
					, CONVERT(BIT, (CASE WHEN CI.BookedForTheory = 'True' 
											AND CI.BookedForPractical = 'True' 
											THEN 'True' 
											ELSE 'False' 
											END)) AS InterpreterForTheoryAndPractical
					, STUFF(
								(
								SELECT ', ' + L1.EnglishName
								FROM dbo.InterpreterLanguage IL1
								INNER JOIN dbo.[Language] L1 ON L1.Id = IL1.LanguageId
								WHERE IL1.InterpreterId = I.Id
								FOR XML PATH('')
								)
								, 1, 2, '')	AS InterpreterLanguageList
			FROM Course C
			INNER JOIN dbo.CourseTypeCategory CTC ON C.CourseTypeCategoryId = CTC.Id
			INNER JOIN dbo.vwCourseDates_SubView CD ON C.Id = CD.CourseId
			LEFT JOIN dbo.vwCourseClientCount_SubView ClientCount ON C.Id = ClientCount.CourseId
			LEFT JOIN dbo.vwCourseTrainerConactenatedTrainers_SubView TrainerCount ON C.Id = TrainerCount.CourseId
			LEFT JOIN dbo.vwCourseInterpreterConcatenatedInterpreters_SubView CIT ON C.Id = CIT.CourseId
			LEFT JOIN dbo.CourseVenue CV ON C.Id = CV.CourseId
			LEFT JOIN dbo.Venue V ON CV.VenueId = V.Id
			LEFT JOIN dbo.CancelledCourse CC ON C.Id = CC.CourseId
			LEFT JOIN dbo.CourseInterpreter CI ON C.Id = CI.CourseId
			LEFT JOIN dbo.Interpreter I ON CI.InterpreterId = I.Id
			LEFT JOIN dbo.Gender G ON I.GenderId = G.Id
			LEFT JOIN dbo.vwCourseInterpreterCount_SubView CICS ON C.Id = CICS.CourseId
																	AND CICS.InterpreterId = CI.InterpreterId
			WHERE I.Id IS NOT NULL;
			
		GO
		/*********************************************************************************************************************/
	