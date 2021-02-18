

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwAllDocumentSummary', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwAllDocumentSummary;
		END		
		GO

		CREATE VIEW dbo.vwAllDocumentSummary
		AS

			SELECT
			  1 AS FakeId  
			, SUM(NumberOfDocuments) AS NumberOfDocuments
			, SUM(TotalSize) AS TotalSize
			, SUM(NumberOfDocumentsThisMonth) AS NumberOfDocumentsThisMonth
			, SUM(TotalSizeOfDocumentsThisMonth) AS TotalSizeOfDocumentsThisMonth
			, SUM(NumberOfDocumentsPreviousMonth) AS NumberOfDocumentsPreviousMonth
			, SUM(TotalSizeOfDocumentsPreviousMonth) AS TotalSizeOfDocumentsPreviousMonth
			, SUM(NumberOfDocumentsThisYear) AS NumberOfDocumentsThisYear
			, SUM(TotalSizeOfDocumentsThisYear) AS TotalSizeOfDocumentsThisYear
			, SUM(NumberOfDocumentsPreviousYear) AS NumberOfDocumentsPreviousYear
			, SUM(TotalSizeOfDocumentsPreviousYear) AS TotalSizeOfDocumentsPreviousYear
			, SUM(NumberOfDocumentsPreviousTwoYears) AS NumberOfDocumentsPreviousTwoYears
			, SUM(TotalSizeOfDocumentsPreviousTwoYears) AS TotalSizeOfDocumentsPreviousTwoYears
			, SUM(NumberOfDocumentsPreviousThreeYears) AS NumberOfDocumentsPreviousThreeYears
			, SUM(TotalSizeOfDocumentsPreviousThreeYears) AS TotalSizeOfDocumentsPreviousThreeYears
			FROM dbo.vwAllDocumentSummaryByOrganisation
			;
		GO

		/*********************************************************************************************************************/
		

		