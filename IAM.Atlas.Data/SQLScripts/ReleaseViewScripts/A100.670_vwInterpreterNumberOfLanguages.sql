		/*
			Drop the View if it already exists
			NB - Used in vwLanguageInterpreter
			And - vwInterpreterLanguage
		*/
		IF OBJECT_ID('dbo.vwInterpreterNumberOfLanguages', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterNumberOfLanguages;
		END		
		GO
		/*
			Create vwInterpreterNumberOfLanguages
		*/
		CREATE VIEW dbo.vwInterpreterNumberOfLanguages
		AS

			SELECT InterpreterId, COUNT(LanguageId) AS NumberOfLanguages
			FROM dbo.InterpreterLanguage
			GROUP BY InterpreterId

		GO

		/*********************************************************************************************************************/