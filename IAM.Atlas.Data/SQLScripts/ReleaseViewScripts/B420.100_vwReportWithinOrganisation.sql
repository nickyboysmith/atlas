
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportWithinOrganisation', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportWithinOrganisation;
END		
GO

/*
	Create View vwReportWithinOrganisation
*/
CREATE VIEW vwReportWithinOrganisation
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
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationReport ORGR			ON ORGR.OrganisationId = O.Id
	INNER JOIN dbo.vwReportDetail R						ON R.ReportId = ORGR.ReportId

	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		