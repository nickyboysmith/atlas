		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationInterpreterLanguage', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationInterpreterLanguage;
		END		
		GO
		/*
			Create vwOrganisationInterpreterLanguage
		*/
		CREATE VIEW dbo.vwOrganisationInterpreterLanguage
		AS
			SELECT 
				LI.OrganisationId							AS OrganisationId
				, LI.OrganisationName						AS OrganisationName
				, LI.LanguageId								AS LanguageId
				, LI.LanguageName							AS LanguageName
				, COUNT(*)									AS NumberOfInterpreters
			FROM dbo.vwLanguageInterpreter LI
			GROUP BY OrganisationId, OrganisationName, LanguageId, LanguageName
			;

		GO

		/*********************************************************************************************************************/