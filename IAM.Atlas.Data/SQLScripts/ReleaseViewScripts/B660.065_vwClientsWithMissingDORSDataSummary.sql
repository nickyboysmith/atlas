/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientsWithMissingDORSDataSummary', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsWithMissingDORSDataSummary;
END		
GO

/*
	Create View vwClientsWithMissingDORSDataSummary
*/

CREATE VIEW dbo.vwClientsWithMissingDORSDataSummary
AS
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, SUM(CASE WHEN ISNULL(DD.CreatedToday, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedToday
		, SUM(CASE WHEN ISNULL(DD.CreatedYesterday, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedYesterday
		, SUM(CASE WHEN ISNULL(DD.CreatedThisWeek, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedThisWeek
		, SUM(CASE WHEN ISNULL(DD.CreatedThisMonth, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedThisMonth
		, SUM(CASE WHEN ISNULL(DD.CreatedLastMonth, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedLastMonth
		, SUM(CASE WHEN ISNULL(DD.CreatedThisYear, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedThisYear
		, SUM(CASE WHEN ISNULL(DD.CreatedBeforeThisYear, 'False') = 'True'
					THEN 1 ELSE 0 END) AS TotalCreatedBeforeThisYear
	FROM dbo.Organisation O
	LEFT JOIN dbo.vwClientsWithMissingDORSData DD	ON DD.OrganisationId = O.Id
	LEFT JOIN dbo.ClientOrganisation CLO			ON CLO.ClientId = DD.ClientId
													AND CLO.OrganisationId = O.Id
	GROUP BY O.Id, O.[Name]
	;
GO
		
/*********************************************************************************************************************/
