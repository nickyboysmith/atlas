
/*
	SCRIPT: Amend the Dashboard Meter View for Documents
	Author: Robert Newnham
	Created: 27/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_09.03_AmendView_vwDashboardMeter_DocumentStats.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_DocumentStats';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	IF EXISTS (SELECT *  
				FROM sys.indexes  
				WHERE name='IDX_vwDashboardMeter_DocumentStats_OrganisationId' 
				AND object_id = OBJECT_ID('[dbo].[vwDashboardMeter_DocumentStats]'))
	BEGIN
		DROP INDEX [IDX_vwDashboardMeter_DocumentStats_OrganisationId] ON [dbo].[vwDashboardMeter_DocumentStats];
	END
	GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_DocumentStats', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_DocumentStats;
	END		
	GO

	/*
		Create View vwDashboardMeter_DocumentStats
	*/
	CREATE VIEW vwDashboardMeter_DocumentStats 
	WITH SCHEMABINDING
	AS
		SELECT 
			ISNULL(OrganisationId,0) AS OrganisationId
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
		FROM dbo.Organisation O
		INNER JOIN dbo.DashboardMeter_DocumentSummary DS ON DS.OrganisationId = O.Id
GO

	--Create an index on the view.  
	CREATE UNIQUE CLUSTERED INDEX IDX_vwDashboardMeter_DocumentStats_OrganisationId
		ON dbo.vwDashboardMeter_DocumentStats (OrganisationId);  
GO  

DECLARE @ScriptName VARCHAR(100) = 'SP022_09.03_AmendView_vwDashboardMeter_DocumentStats.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
