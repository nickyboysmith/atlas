
--vwDashboardMeter_AttendanceNotUploadedToDORS
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDashboardMeter_AttendanceNotUploadedToDORS', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDashboardMeter_AttendanceNotUploadedToDORS;
END		
GO
/*
	Create vwDashboardMeter_AttendanceNotUploadedToDORS
*/
CREATE VIEW vwDashboardMeter_AttendanceNotUploadedToDORS
AS
	SELECT
		OrganisationId
		, OrganisationName
		, DateAndTimeRefreshed
		, TotalAttendanceNotUploadedToDORS
	FROM [dbo].[DashboardMeterData_AttendanceNotUploadedToDORS] O
	;
	
GO


/*********************************************************************************************************************/