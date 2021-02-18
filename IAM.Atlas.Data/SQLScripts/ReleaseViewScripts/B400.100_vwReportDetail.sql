
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportDetail;
END		
GO

/*
	Create View vwReportDetail
*/
CREATE VIEW vwReportDetail
AS	
	SELECT 
		R.Id							AS ReportId
		, R.Title						AS ReportTitle
		, R.[Description]				AS ReportDescription
		, R.AtlasSystemReport			AS AtlasSystemReport
		, R.Landscape					AS LandscapeReport
		, R.ChangeNo					AS ReportVersion
		, RDG.Id						AS ReportDataGridId
		, DV.Id							AS ReportDataViewId
		, DV.[Name]						AS ReportDataViewName
		, DV.Title						AS ReportDataViewTitle
		, DV.[Enabled]					AS ReportDataViewEnabled
		, COUNT(DISTINCT RP.Id)			AS NumberOfReportParameters
		, COUNT(DISTINCT RC.Title)		AS NumberOfReportCategories
	FROM dbo.Report R
	INNER JOIN dbo.ReportDataGrid RDG				ON RDG.ReportId = R.Id
	INNER JOIN dbo.DataView DV						ON DV.Id = RDG.DataViewId
	LEFT JOIN dbo.ReportParameter RP				ON RP.ReportDataGridId = RDG.Id
	LEFT JOIN dbo.ReportsReportCategory RRC			ON RRC.ReportId = R.Id
	LEFT JOIN dbo.ReportCategory RC					ON RC.Id = RRC.ReportCategoryId
	GROUP BY
		R.Id
		, R.Title
		, R.[Description]
		, R.AtlasSystemReport
		, R.Landscape
		, R.ChangeNo
		, RDG.Id
		, DV.Id
		, DV.[Name]
		, DV.Title
		, DV.[Enabled]
	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		