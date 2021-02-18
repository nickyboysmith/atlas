
/*
	Drop the View if it already exists
*/		
IF OBJECT_ID('dbo.vwDashboardMeter_Clients', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDashboardMeter_Clients;
END		
GO

/*
	Create View vwDashboardMeter_Clients
*/
CREATE VIEW vwDashboardMeter_Clients
AS
	SELECT
		OrganisationId
		, OrganisationName
		, DateAndTimeRefreshed
		, TotalClients
		, RegisteredOnlineToday
		, RegisteredToday
		, RegisteredOnlineYesterday
		, RegisteredYesterday
		, NumberOfUnpaidCourses
		, TotalAmountUnpaid
		, ClientsWithRequirementsRegisteredOnlineToday
		, TotalUpcomingClientsWithRequirements
		, UnableToUpdateInDORS
		, AttendanceNotUploadedToDORS
		, ClientsWithMissingReferringAuthorityCreatedThisWeek
		, ClientsWithMissingReferringAuthorityCreatedThisMonth
		, ClientsWithMissingReferringAuthorityCreatedLastMonth
	FROM [dbo].[DashboardMeterData_Client] C
	;
GO

/*********************************************************************************************************************/
		