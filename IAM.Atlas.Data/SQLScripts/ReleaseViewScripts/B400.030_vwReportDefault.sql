
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportDefault', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportDefault;
END		
GO

/*
	Create View vwReportDefault
*/
CREATE VIEW vwReportDefault
AS	
	SELECT 
		SC.ReportDefaultPageSize
		, SC.ReportDefaultPageOrientation
		, SC.ReportDefaultPortraitRowsPerPage
		, SC.ReportDefaultLanscapeRowsPerPage
		, SC.ReportMaximumRows
	FROM dbo.SystemControl SC
	WHERE SC.Id = 1
	;
	/*****************************************************************************************************************/
GO
	
/*********************************************************************************************************************/
		