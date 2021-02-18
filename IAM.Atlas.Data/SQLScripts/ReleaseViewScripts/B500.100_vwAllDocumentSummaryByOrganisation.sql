

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwAllDocumentSummaryByOrganisation', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwAllDocumentSummaryByOrganisation;
		END		
		GO

		CREATE VIEW dbo.vwAllDocumentSummaryByOrganisation
		AS
			SELECT O.Id AS OrganisationId
				, COUNT_BIG(D.Id) AS NumberOfDocuments
				, SUM(ISNULL(D.FileSize, 0)) AS TotalSize
				, SUM(CASE WHEN MONTH(D.DateUpdated) = MONTH(GetDate()) THEN 1 ELSE 0 END) AS NumberOfDocumentsThisMonth
				, SUM(CASE WHEN MONTH(D.DateUpdated) = MONTH(GetDate()) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsThisMonth
				, SUM(CASE WHEN MONTH(D.DateUpdated) = (MONTH(GetDate()) - 1) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousMonth
				, SUM(CASE WHEN MONTH(D.DateUpdated) = (MONTH(GetDate()) - 1) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousMonth
				, SUM(CASE WHEN YEAR(D.DateUpdated) = YEAR(GetDate()) THEN 1 ELSE 0 END) AS NumberOfDocumentsThisYear
				, SUM(CASE WHEN YEAR(D.DateUpdated) = YEAR(GetDate()) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsThisYear
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 1) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousYear
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 1) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousYear
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 2) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousTwoYears
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 2) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousTwoYears
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 3) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousThreeYears
				, SUM(CASE WHEN YEAR(D.DateUpdated) = (YEAR(GetDate()) - 3) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousThreeYears
			FROM dbo.Organisation O
			LEFT JOIN dbo.DocumentOwner DO ON DO.OrganisationId = O.Id
			LEFT JOIN dbo.Document D ON D.Id = DO.DocumentId
			GROUP BY O.Id
			;

		GO
		/*********************************************************************************************************************/