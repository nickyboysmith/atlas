		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseInterpretersWithoutEmail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseInterpretersWithoutEmail;
		END		
		GO
		/*
			Create vwCourseInterpretersWithoutEmail
		*/

		CREATE VIEW dbo.vwCourseInterpretersWithoutEmail 
		AS
			SELECT
				ISNULL(C.OrganisationId,0)				AS OrganisationId
				, ISNULL(C.Id,0)						AS CourseId
				, CT.Title								AS CourseType
				, CT.Id									AS CourseTypeId
				, CTC.Id								AS CourseTypeCategoryId
				, CTC.[Name]							AS CourseTypeCategory
				, C.Reference							AS CourseReference
				, CD.StartDate							AS CourseStartDate
				, CD.EndDate							AS CourseEndDate
				, I.Id									AS InterpreterId
				, (CASE WHEN I.DisplayName IS NULL 
						THEN LTRIM(RTRIM(
								ISNULL(I.Title,'') 
								+ ' ' + ISNULL(I.FirstName,'') 
								+ ' ' + ISNULL(I.Surname,'')
								))
						ELSE I.DisplayName END)			AS InterpreterName
				, G.Id									AS InterpreterGenderId
				, G.[Name]								AS InterpreterGender
				, L.[Address]							AS InterpreterAddress
				, L.PostCode							AS InterpreterPostCode


				, IP.InterpreterMainPhoneNumber			AS InterpreterMainPhoneNumber
				, IP.InterpreterMainPhoneTypeId			AS InterpreterMainPhoneTypeId
				, IP.InterpreterMainPhoneType			AS InterpreterMainPhoneType
				, IP.InterpreterSecondPhoneNumber		AS InterpreterSecondPhoneNumber
				, IP.InterpreterSecondPhoneTypeId		AS InterpreterSecondPhoneTypeId
				, IP.InterpreterSecondPhoneType			AS InterpreterSecondPhoneType
				, I.DateOfBirth							AS InterpreterDateOfBirth
			FROM dbo.Course C
			INNER JOIN dbo.vwCourseDates_SubView CD		ON CD.CourseId = C.id
			INNER JOIN dbo.CourseType CT				ON CT.Id = C.CourseTypeId
			INNER JOIN dbo.CourseInterpreter CI			ON C.Id = CI.CourseId
			INNER JOIN dbo.Interpreter I				ON CI.InterpreterId = I.Id
			INNER JOIN dbo.Gender G						ON I.GenderId = G.Id
			LEFT JOIN dbo.CourseTypeCategory CTC		ON C.CourseTypeCategoryId = CTC.Id
			LEFT JOIN dbo.InterpreterLocation IL		ON I.Id = IL.InterpreterId
															AND IL.Main = 'True'
			LEFT JOIN dbo.[Location] L					ON IL.LocationId = L.Id
			LEFT JOIN dbo.InterpreterEmail IEM			ON I.Id = IEM.InterpreterId
															AND IEM.Main = 'True'
			LEFT JOIN dbo.Email E						ON E.Id = IEM.EmailId

			--LEFT JOIN dbo.[Location] L						ON L.Id = TLO.LocationId
			LEFT JOIN vwInterpreterPhoneRow IP			ON IP.InterpreterId = CI.InterpreterId
			WHERE (IEM.Id IS NULL
				OR E.Id IS NULL
				OR dbo.udfIsEmailAddressValid(E.[Address]) = 'False'
				)
			;

			GO
		/*********************************************************************************************************************/