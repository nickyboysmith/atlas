
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportRequest', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportRequest;
END		
GO

/*
	Create View vwReportRequest
*/
CREATE VIEW vwReportRequest
AS	
	SELECT 
		RR.Id									AS ReportRequestId
		, RR.OrganisationId						AS OrganisationId
		, U.Id									AS CreatedByUserId
		, U.[Name]								AS CreatedByUserName
		, R.ReportId				
		, R.ReportTitle
		, dbo.udfGetReportSubTitle(RR.Id)		AS ReportSubTitle
		, R.ReportDescription
		, R.AtlasSystemReport
		, R.LandscapeReport
		, R.ReportDataViewId
		, R.ReportDataViewName
		, R.ReportDataViewTitle
		, R.ReportDataViewEnabled
		, R.NumberOfReportParameters
		, R.NumberOfReportCategories
		, RR.NumberOfDataRows
		, COUNT(RRP.Id)							AS NumberOfReportRequestParameters
	FROM dbo.ReportRequest RR
	INNER JOIN dbo.[User] U							ON U.Id = RR.CreatedByUserId
	INNER JOIN dbo.vwReportDetail R					ON R.ReportId = RR.ReportId
	LEFT JOIN dbo.ReportRequestParameter RRP		ON RRP.ReportRequestId = RR.Id
	GROUP BY
		RR.Id
		, RR.OrganisationId
		, U.Id
		, U.[Name]
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
		, RR.NumberOfDataRows
	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		