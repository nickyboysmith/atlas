
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportColumn', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportColumn;
END		
GO

/*
	Create View vwReportColumn
*/
CREATE VIEW vwReportColumn
AS	
	SELECT 
		R.Id						AS ReportId
		, RD.ReportTitle			AS ReportTitle
		, RD.ReportDescription		AS ReportDescription
		, RD.AtlasSystemReport		AS AtlasSystemReport
		, RD.LandscapeReport		AS LandscapeReport
		, RD.ReportDataGridId		AS ReportDataGridId
		, RD.ReportDataViewId		AS ReportDataViewId
		, RD.ReportDataViewName		AS ReportDataViewName
		, DVC.Id					AS ColumnId
		, DVC.[Name]				AS ColumnName
		, (CASE WHEN LEN(ISNULL(RDGC.[ColumnTitle],'')) <= 0
				THEN DVC.Title
				ELSE RDGC.[ColumnTitle]
				END)				AS ColumnTitle
		, RDGC.DisplayOrder			AS ColumnDisplayOrder
		, RDGC.SortOrder			AS ColumnSortOrder
		, DVC.DataType				AS ColumnDataType
	FROM dbo.Report R
	INNER JOIN dbo.vwReportDetail RD ON RD.ReportId = R.Id
	INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.[ReportDataGridId] = RD.ReportDataGridId
	INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[Id] = RDGC.[DataViewColumnId]
	WHERE DVC.Removed = 'False'
	;
	/*****************************************************************************************************************/
GO
	