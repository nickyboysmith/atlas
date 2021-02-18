
--vwDashboardMeter_UnableToUpdateInDORS
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDashboardMeter_UnableToUpdateInDORS', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDashboardMeter_UnableToUpdateInDORS;
END		
GO
/*
	Create vwDashboardMeter_UnableToUpdateInDORS
*/
CREATE VIEW vwDashboardMeter_UnableToUpdateInDORS
AS
	SELECT
		OrganisationId
		, OrganisationName
		, DateAndTimeRefreshed
		, TotalClientsUnableToUpdateInDORS
	FROM [dbo].[DashboardMeterData_UnableToUpdateInDORS] O
	;
	
GO


/*********************************************************************************************************************/
