
--vwDashboardMeter_OnlineClientsSpecialRequirement
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDashboardMeter_OnlineClientsSpecialRequirement', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDashboardMeter_OnlineClientsSpecialRequirement;
END		
GO
/*
	Create vwDashboardMeter_OnlineClientsSpecialRequirement
*/
CREATE VIEW vwDashboardMeter_OnlineClientsSpecialRequirement
AS
	SELECT
		OrganisationId
		, OrganisationName
		, DateAndTimeRefreshed
		, ClientsWithRequirementsRegisteredOnlineToday
		, TotalUpcomingClientsWithRequirements
	FROM [dbo].[DashboardMeterData_OnlineClientsSpecialRequirement] O
	;
	--SELECT  organisationid
	--		, SUM(CASE WHEN CAST(C.[DateCreated] AS DATE) = CAST((Getdate()) AS DATE)
	--							THEN 1 ELSE 0 END) AS ClientsWithRequirementsRegisteredOnlineToday
	--		, count(c.Id) as TotalUpcomingClientsWithRequirements
	--FROM client c
	--INNER JOIN [ClientOnlineBookingState] cobs ON cobs.clientid = c.id
	--INNER JOIN Course on cobs.courseid = course.id
	--INNER JOIN [ClientSpecialRequirement] csr ON csr.clientid = c.id
	--INNER JOIN vwCourseDates_SubView cd ON course.id = cd.courseid
	--WHERE cd.startdate > GETDATE()
	--and cobs.coursebooked = 'true' and cobs.FullPaymentRecieved = 'true'
	--GROUP BY organisationid;
GO


/*********************************************************************************************************************/
