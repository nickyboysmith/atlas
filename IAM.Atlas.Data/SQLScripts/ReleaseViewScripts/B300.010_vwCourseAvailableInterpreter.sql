

--vwCourseAvailableInterpreter
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseAvailableInterpreter', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseAvailableInterpreter;
END		
GO
/*
	Create vwCourseAvailableInterpreter
*/
CREATE VIEW vwCourseAvailableInterpreter
AS
	SELECT DISTINCT
		ISNULL(C.OrganisationId,0)												AS OrganisationId
		, ISNULL(C.Id,0)														AS CourseId
		, CType.Title															AS CourseType
		, CType.Id																AS CourseTypeId
		, C.Reference															AS CourseReference
		, MIN(CD.DateStart)														AS CourseStartDate
		, MAX(CD.DateEnd)														AS CourseEndDate
		, IABD.InterpreterId													AS InterpreterId
		, (CASE WHEN LEN(ISNULL(I.[DisplayName],'')) <= 0 
				THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
				ELSE I.[DisplayName] END)										AS InterpreterName
		, I.[GenderId]															AS InterpreterGenderId
		, G.[Name]																AS InterpreterGender
		, STUFF(
					(
					SELECT ', ' + L1.EnglishName
					FROM dbo.InterpreterLanguage IL1
					INNER JOIN dbo.[Language] L1 ON L1.Id = IL1.LanguageId
					WHERE IL1.InterpreterId = IABD.InterpreterId
					FOR XML PATH('')
					)
					, 1, 2, '')													AS InterpreterLanguageList
	FROM Course C
	INNER JOIN dbo.CourseDate CD								ON CD.CourseId = C.Id
	INNER JOIN dbo.CourseVenue CV								ON CV.CourseId = C.Id
	INNER JOIN dbo.Venue V										ON V.Id = CV.VenueId
	INNER JOIN dbo.CourseType CType								ON CType.Id = C.CourseTypeId
	INNER JOIN [dbo].[vwInterpreterAvailabilityByDate] IABD		ON IABD.[Date] = CAST(CD.DateStart AS DATE)
	INNER JOIN [dbo].[Interpreter] I							ON I.Id = IABD.InterpreterId
	INNER JOIN dbo.InterpreterOrganisation IORG					ON IORG.InterpreterId = I.Id
																	AND IORG.OrganisationId = c.OrganisationId
	INNER JOIN [dbo].[Gender] G									ON G.Id = I.[GenderId]
	LEFT JOIN dbo.CancelledCourse CC							ON CC.CourseId = C.Id
	WHERE CD.DateStart >= GETDATE() --future bookings
	AND CC.Id IS NULL /* Course Must not be Cancelled */
	GROUP BY
		C.OrganisationId
		, C.Id
		, CType.Title
		, CType.Id
		, C.Reference
		, IABD.InterpreterId
		, I.[DisplayName]
		, I.[Title], I.[FirstName], I.[Surname]
		, I.[GenderId]
		, G.[Name]
	;
	
GO


/*********************************************************************************************************************/
