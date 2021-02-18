/*
	SCRIPT: Create a SP to update Table DashboardMeter_DocumentSummary to Hold Dashboard Meter View for Documents Statistics
	Author: Robert Newnham
	Created: 27/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_09.02_CreateSPUpdateDashboardMeter_DocumentSummary.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a SP to update Table DashboardMeter_DocumentSummary to Hold Dashboard Meter View for Documents Statistics';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspUpdateDashboardMeter_DocumentSummary', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspUpdateDashboardMeter_DocumentSummary;
	END		
	GO

	/*
		Create uspUpdateDashboardMeter_DocumentSummary
	*/

	CREATE PROCEDURE dbo.uspUpdateDashboardMeter_DocumentSummary @OrganisationId INT = NULL
	AS
	BEGIN
		--NB If @OrganisationId is not passed the SP will Update for All Organisations
		SELECT DO.OrganisationId
			, COUNT_BIG(*) AS NumberOfDocuments
			, SUM(D.FileSize) AS TotalSize
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
		INTO #DocSummary
		FROM dbo.Document D
		LEFT JOIN dbo.DocumentOwner DO ON DO.DocumentId = D.Id
		--FROM dbo.DocumentOwner DO
		--INNER JOIN dbo.Document D ON D.Id = DO.DocumentId
		WHERE DO.OrganisationId = (CASE WHEN @OrganisationId IS NULL THEN DO.OrganisationId ELSE @OrganisationId END)
		GROUP BY DO.OrganisationId;

		--FIRST INSERT MISSING
		INSERT INTO DashboardMeter_DocumentSummary (OrganisationId
													, NumberOfDocuments
													, TotalSize
													, NumberOfDocumentsThisMonth
													, TotalSizeOfDocumentsThisMonth
													, NumberOfDocumentsPreviousMonth
													, TotalSizeOfDocumentsPreviousMonth
													, NumberOfDocumentsThisYear
													, TotalSizeOfDocumentsThisYear
													, NumberOfDocumentsPreviousYear
													, TotalSizeOfDocumentsPreviousYear
													, NumberOfDocumentsPreviousTwoYears
													, TotalSizeOfDocumentsPreviousTwoYears
													, NumberOfDocumentsPreviousThreeYears
													, TotalSizeOfDocumentsPreviousThreeYears
													)
		SELECT OrganisationId
			, NumberOfDocuments
			, TotalSize
			, NumberOfDocumentsThisMonth
			, TotalSizeOfDocumentsThisMonth
			, NumberOfDocumentsPreviousMonth
			, TotalSizeOfDocumentsPreviousMonth
			, NumberOfDocumentsThisYear
			, TotalSizeOfDocumentsThisYear
			, NumberOfDocumentsPreviousYear
			, TotalSizeOfDocumentsPreviousYear
			, NumberOfDocumentsPreviousTwoYears
			, TotalSizeOfDocumentsPreviousTwoYears
			, NumberOfDocumentsPreviousThreeYears
			, TotalSizeOfDocumentsPreviousThreeYears
		FROM #DocSummary DS
		WHERE NOT EXISTS (SELECT * 
							FROM DashboardMeter_DocumentSummary DMDS
							WHERE DMDS.OrganisationId = DS.OrganisationId);

							
		--SECOND UPDATE EXISTING
		UPDATE DMDS
		SET 
			DMDS.OrganisationId = DS.OrganisationId
			, DMDS.NumberOfDocuments = DS.NumberOfDocuments
			, DMDS.TotalSize = DS.TotalSize
			, DMDS.NumberOfDocumentsThisMonth = DS.NumberOfDocumentsThisMonth
			, DMDS.TotalSizeOfDocumentsThisMonth = DS.TotalSizeOfDocumentsThisMonth
			, DMDS.NumberOfDocumentsPreviousMonth = DS.NumberOfDocumentsPreviousMonth
			, DMDS.TotalSizeOfDocumentsPreviousMonth = DS.TotalSizeOfDocumentsPreviousMonth
			, DMDS.NumberOfDocumentsThisYear = DS.NumberOfDocumentsThisYear
			, DMDS.TotalSizeOfDocumentsThisYear = DS.TotalSizeOfDocumentsThisYear
			, DMDS.NumberOfDocumentsPreviousYear = DS.NumberOfDocumentsPreviousYear
			, DMDS.TotalSizeOfDocumentsPreviousYear = DS.TotalSizeOfDocumentsPreviousYear
			, DMDS.NumberOfDocumentsPreviousTwoYears = DS.NumberOfDocumentsPreviousTwoYears
			, DMDS.TotalSizeOfDocumentsPreviousTwoYears = DS.TotalSizeOfDocumentsPreviousTwoYears
			, DMDS.NumberOfDocumentsPreviousThreeYears = DS.NumberOfDocumentsPreviousThreeYears
			, DMDS.TotalSizeOfDocumentsPreviousThreeYears = DS.TotalSizeOfDocumentsPreviousThreeYears
		FROM DashboardMeter_DocumentSummary DMDS
		INNER JOIN #DocSummary DS ON DS.OrganisationId = DMDS.OrganisationId

	END
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_09.02_CreateSPUpdateDashboardMeter_DocumentSummary.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO