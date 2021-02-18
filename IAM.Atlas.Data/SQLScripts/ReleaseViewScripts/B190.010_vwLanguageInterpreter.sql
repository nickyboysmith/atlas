		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwLanguageInterpreter', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwLanguageInterpreter;
		END		
		GO
		/*
			Create vwLanguageInterpreter
		*/
		CREATE VIEW dbo.vwLanguageInterpreter
		AS
			SELECT O.Id											AS OrganisationId
				, O.[Name]										AS OrganisationName
				, L.Id											AS LanguageId
				, L.EnglishName									AS LanguageName
				, I.Id											AS InterpreterId
				, (CASE WHEN 
					LEN(ISNULL(I.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(I.[Title] + ' ' + I.[FirstName] + ' ' + I.[Surname]))
									ELSE I.[DisplayName] 
									END)						AS InterpreterName
				, G.Id											AS InterpreterGenderId
				, G.[Name]										AS InterpreterGender
				, INL.NumberOfLanguages							AS NumberOfLanguages
				, STUFF(
							(
							SELECT ', ' + L1.EnglishName
							FROM dbo.InterpreterLanguage IL1
							INNER JOIN dbo.[Language] L1 ON L1.Id = IL1.LanguageId
							WHERE IL1.InterpreterId = IL.InterpreterId
							FOR XML PATH('')
							)
							, 1, 2, '')							AS InterpreterLanguageList
			FROM dbo.InterpreterLanguage IL
			INNER JOIN dbo.Interpreter I ON IL.InterpreterId = I.Id
			INNER JOIN dbo.[Language] L ON IL.LanguageId = L.Id
			INNER JOIN dbo.InterpreterOrganisation INTORG ON I.Id = INTORG.InterpreterId
			INNER JOIN dbo.Organisation O ON INTORG.OrganisationId = O.ID
			INNER JOIN dbo.Gender G ON I.GenderId = G.Id
			INNER JOIN dbo.vwInterpreterNumberOfLanguages INL ON I.Id = INL.InterpreterId
			;

		GO

		/*********************************************************************************************************************/