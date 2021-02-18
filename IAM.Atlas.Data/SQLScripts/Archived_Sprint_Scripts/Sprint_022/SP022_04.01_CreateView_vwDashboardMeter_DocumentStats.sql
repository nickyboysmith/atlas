
/*
	SCRIPT: Create a Dashboard Meter View for Documents
	Author: Robert Newnham
	Created: 17/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_04.01_CreateView_vwDashboardMeter_DocumentStats.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_DocumentStats';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
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
	CREATE VIEW vwDashboardMeter_DocumentStats AS	
	
		SELECT DO.OrganisationId
			, COUNT(*) AS NumberOfDocuments
			, SUM(D.FileSize) AS TotalSize
			, SUM(CASE WHEN DATEPART(m, D.DateUpdated) = DATEPART(m, GetDate()) THEN 1 ELSE 0 END) AS NumberOfDocumentsThisMonth
			, SUM(CASE WHEN DATEPART(m, D.DateUpdated) = DATEPART(m, GetDate()) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsThisMonth
			, SUM(CASE WHEN DATEPART(m, D.DateUpdated) = DATEPART(m, DATEADD(m, -1, GetDate())) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousMonth
			, SUM(CASE WHEN DATEPART(m, D.DateUpdated) = DATEPART(m, DATEADD(m, -1, GetDate())) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousMonth
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, GetDate()) THEN 1 ELSE 0 END) AS NumberOfDocumentsThisYear
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, GetDate()) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsThisYear
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -1, GetDate())) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousYear
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -1, GetDate())) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousYear
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -2, GetDate())) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousTwoYears
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -2, GetDate())) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousTwoYears
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -3, GetDate())) THEN 1 ELSE 0 END) AS NumberOfDocumentsPreviousThreeYears
			, SUM(CASE WHEN DATEPART(Y, D.DateUpdated) = DATEPART(Y, DATEADD(Y, -3, GetDate())) THEN D.FileSize ELSE 0 END) AS TotalSizeOfDocumentsPreviousThreeYears
		FROM Document D
		LEFT JOIN DocumentOwner DO ON DO.DocumentId = D.Id
		GROUP BY DO.OrganisationId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_04.01_CreateView_vwDashboardMeter_DocumentStats.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
