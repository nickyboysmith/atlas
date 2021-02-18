
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportParameter', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportParameter;
END		
GO

/*
	Create View vwReportParameter
*/
CREATE VIEW vwReportParameter
AS	
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, R.ReportId
		, R.ReportTitle
		, R.ReportDescription
		, R.AtlasSystemReport
		, R.LandscapeReport
		, R.ReportDataViewId
		, R.ReportDataViewName
		, R.ReportDataViewTitle
		, R.ReportDataViewEnabled
		, R.NumberOfReportParameters
		, R.NumberOfReportCategories
		, RP.Id							AS ReportParameterId
		, RP.Title						AS ReportParameterTitle
		, RP.DataViewColumnId			AS ReportDataViewColumnId
		, DVC.[Name]					AS ReportDataViewColumnName
		, DVC.Title						AS ReportDataViewColumnTitle
		, DVC.DataType					AS ReportDataViewColumnDataType
		, RDT.Id						AS ReportDataTypeId
		, RDT.Title						AS ReportDataTypeTitle
		, RDT.DataTypeName				AS ReportDataTypeName
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationReport ORGR			ON ORGR.OrganisationId = O.Id
	INNER JOIN dbo.vwReportDetail R					ON R.ReportId = ORGR.ReportId
	LEFT JOIN dbo.ReportParameter RP				ON RP.ReportDataGridId = R.ReportDataGridId
	LEFT JOIN dbo.DataViewColumn DVC				ON DVC.Id = RP.DataViewColumnId
	LEFT JOIN dbo.ReportDataType RDT				ON RDT.Id = RP.ReportDataTypeId
	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		