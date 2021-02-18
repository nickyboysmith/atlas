
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportWithinCategory', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportWithinCategory;
END		
GO

/*
	Create View vwReportWithinCategory
*/
CREATE VIEW vwReportWithinCategory
AS	
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName	
		, RC.Id							AS ReportCategoryId
		, RC.Title						AS ReportCategoryTitle
		, RC.[Disabled]					AS ReportCategoryDisabled
		, R.ReportId					AS ReportId
		, R.ReportTitle					AS ReportTitle
		, R.ReportDescription			AS ReportDescription
		, R.AtlasSystemReport			AS AtlasSystemReport
		, R.LandscapeReport				AS LandscapeReport
		, R.ReportDataViewId			AS ReportDataViewId
		, R.ReportDataViewName			AS ReportDataViewName
		, R.ReportDataViewTitle			AS ReportDataViewTitle
		, R.ReportDataViewEnabled		AS ReportDataViewEnabled
		, R.NumberOfReportParameters	AS NumberOfReportParameters
		, R.NumberOfReportCategories	AS NumberOfReportCategories
	FROM dbo.Organisation O
	INNER JOIN dbo.OrganisationReportCategory ORCat		ON ORCat.OrganisationId = O.Id
	INNER JOIN dbo.ReportCategory RC					ON RC.Id = ORCat.OrganisationId
	INNER JOIN dbo.ReportsReportCategory RRC			ON RRC.ReportCategoryId = RC.Id
	INNER JOIN vwReportDetail R							ON R.ReportId = RRC.ReportId

	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		