
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportRequestParameter', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportRequestParameter;
END		
GO

/*
	Create View vwReportRequestParameter
*/
CREATE VIEW vwReportRequestParameter
AS	
	SELECT 
		RR.ReportRequestId
		, RR.CreatedByUserId
		, RR.CreatedByUserName
		, RR.ReportId
		, RR.ReportTitle
		, RR.ReportDescription
		, RR.AtlasSystemReport
		, RR.LandscapeReport
		, RR.ReportDataViewId
		, RR.ReportDataViewName
		, RR.ReportDataViewTitle
		, RR.ReportDataViewEnabled
		, RR.NumberOfReportParameters
		, RR.NumberOfReportCategories
		, RR.NumberOfReportRequestParameters
		, RP.Id							AS ReportParameterId
		, RP.Title						AS ReportParameterTitle
		, RP.DataViewColumnId			AS ReportDataViewColumnId
		, DVC.[Name]					AS ReportDataViewColumnName
		, DVC.Title						AS ReportDataViewColumnTitle
		, DVC.DataType					AS ReportDataViewColumnDataType
		, RDT.Id						AS ReportDataTypeId
		, RDT.Title						AS ReportDataTypeTitle
		, RDT.DataTypeName				AS ReportDataTypeName
		, RRP.Id						AS ReportRequestParameterId
		, RRP.ParameterValue			AS ReportRequestParameterValue
		, RRP.ParameterValueText		AS ReportRequestParameterValueText
		, CAST(
				(CASE WHEN RDT.DataTypeName = 'BDate' 
				AND CAST(RRP.ParameterValue AS DATETIME) = T.StartBDate
				THEN 'True' ELSE 'False' END) 
				AS BIT)					AS FirstBDate
	FROM dbo.vwReportRequest RR
	LEFT JOIN dbo.ReportRequestParameter RRP		ON RRP.ReportRequestId = RR.ReportRequestId
	LEFT JOIN dbo.ReportParameter RP				ON RP.Id = RRP.ReportParameterId
	LEFT JOIN dbo.DataViewColumn DVC				ON DVC.Id = RP.DataViewColumnId
	LEFT JOIN dbo.ReportDataType RDT				ON RDT.Id = RP.ReportDataTypeId
	LEFT JOIN (SELECT RRP2.ReportRequestId, MIN(CAST(RRP2.ParameterValue AS DATETIME)) StartBDate
				FROM [dbo].[ReportRequestParameter] RRP2
				INNER JOIN dbo.ReportParameter RP2	ON RP2.Id = RRP2.ReportParameterId
				INNER JOIN dbo.ReportDataType RDT2	ON RDT2.Id = RP2.ReportDataTypeId
				WHERE RDT2.DataTypeName = 'BDate'
				GROUP BY RRP2.ReportRequestId
				) T ON T.ReportRequestId = RR.ReportRequestId
	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		