		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwInterpreterLanguage', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterLanguage;
		END		
		GO
		/*
			Create vwLanguageInterpreter
		*/
		CREATE VIEW dbo.vwInterpreterLanguage
		AS
			SELECT O.Id											AS OrganisationId
				, O.[Name]										AS OrganisationName
				, I.Id											AS InterpreterId
				, (CASE WHEN 
					LEN(ISNULL(I.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
									ELSE I.[DisplayName] 
									END)						AS InterpreterName
				, G.Id											AS InterpreterGenderId
				, G.[Name]										AS InterpreterGender
				, INL.NumberOfLanguages							AS NumberOfLanguages
				, L.Id											AS LanguageId
				, L.EnglishName									AS LanguageName
			FROM dbo.InterpreterLanguage IL
			INNER JOIN dbo.Interpreter I ON IL.InterpreterId = I.Id
			INNER JOIN dbo.[Language] L ON IL.LanguageId = L.Id
			INNER JOIN dbo.InterpreterOrganisation INTORG ON I.Id = INTORG.InterpreterId
			INNER JOIN dbo.Organisation O ON INTORG.OrganisationId = O.ID
			INNER JOIN dbo.Gender G ON I.GenderId = G.Id
			INNER JOIN dbo.vwInterpreterNumberOfLanguages INL ON I.Id = INL.InterpreterId;

		GO

		/*********************************************************************************************************************/