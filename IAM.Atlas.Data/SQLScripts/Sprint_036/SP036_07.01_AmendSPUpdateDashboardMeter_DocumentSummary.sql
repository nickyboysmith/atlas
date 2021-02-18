/*
	SCRIPT: Amend SP DashboardMeter_DocumentSummary to use View vwAllDocumentSummaryByOrganisation for Documents Statistics
	Author: Nick Smith
	Created: 12/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_07.01_AmendSPUpdateDashboardMeter_DocumentSummary.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP DashboardMeter_DocumentSummary to use View vwAllDocumentSummaryByOrganisation for Documents Statistics';
		
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
		INTO #DocSummary
		FROM dbo.vwAllDocumentSummaryByOrganisation

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

DECLARE @ScriptName VARCHAR(100) = 'SP036_07.01_AmendSPUpdateDashboardMeter_DocumentSummary.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO