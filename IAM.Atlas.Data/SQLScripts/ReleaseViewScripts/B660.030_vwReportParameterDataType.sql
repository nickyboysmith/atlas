/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportParameterDataType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportParameterDataType;
END		
GO

/*
	Create vwReportParameterDataType
*/
CREATE VIEW vwReportParameterDataType
AS
	SELECT  rdg.ReportId						AS  ReportId
			, rdg.Id							AS  ReportDataGridId
			, dv.DataViewId						AS	DataViewId		 
			, dv.Id								AS	DataViewColumnId
			, dv.Name							AS	DataViewName
			, dv.Title							AS	DataViewTitle
			, dv.DataType						AS	DataType
			, rdtsi.SelectIdentifier			AS  SelectIdentifier
			, rdt.DataTypeName 					AS  DataTypeName 
			, rdt.Id							AS  ReportDataTypeId 
	FROM ReportDataGrid rdg
	INNER JOIN DataViewColumn dv ON dv.DataViewId = rdg.DataViewId 
	INNER JOIN ReportDataTypeSelectIdentifier rdtsi ON rdtsi.SelectIdentifier = dv.Name
	INNER JOIN ReportDataType rdt ON rdt.Id = rdtsi.ReportDataTypeId
	UNION
	SELECT  rdg.ReportId						AS  ReportId
			, rdg.Id							AS  ReportDataGridId
			, dv.DataViewId						AS	DataViewId		 
			, dv.Id								AS  DataViewColumnId
			, dv.Name							AS	DataViewName
			, dv.Title							AS	DataViewTitle
			, dv.DataType						AS	DataType
			, rdtsi.SelectIdentifier			AS  SelectIdentifier
			, rdt.DataTypeName					AS  DataTypeName
			, rdt.Id							AS  ReportDataTypeId 
	FROM ReportDataGrid rdg
	INNER JOIN DataViewColumn dv ON dv.DataViewId = rdg.DataViewId 
	LEFT JOIN ReportDataTypeSelectIdentifier rdtsi ON rdtsi.SelectIdentifier = dv.Name
	CROSS JOIN ReportDataType rdt
	WHERE rdtsi.id IS NULL
	AND (
		(dv.DataType = 'Text' AND rdt.DataTypeName IN ('String'))
		OR (dv.DataType = 'Boolean' AND rdt.DataTypeName IN ('Boolean'))
		OR (dv.DataType in ('Float', 'Real') AND rdt.DataTypeName IN ('Decimal'))
		OR (dv.DataType = 'DateTime' AND rdt.DataTypeName IN ('Date', 'BDate'))
		OR (dv.DataType = 'Number' AND rdt.DataTypeName IN ('Number', 'Currency', 'Decimal'))
		)
	;

GO

/*********************************************************************************************************************/
