/*
	SCRIPT: Create a Dashboard Meter View for Clients
	Author: Robert Newnham
	Created: 08/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.06_CreateView_vwDashboardMeter_Clients.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_Clients';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_Clients', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_Clients;
	END		
	GO

	/*
		Create View vwDashboardMeter_Clients
	*/
	CREATE VIEW vwDashboardMeter_Clients AS	
		SELECT 
			O.Id As OrganisationId
			, O.Name AS OrganisationName
			, COUNT(*) AS TotalClients
			, SUM(CASE WHEN C.[SelfRegistration] = 'True' 
						AND CAST(C.[DateCreated] AS DATE) = CAST(Getdate() AS DATE)
						THEN 1 ELSE 0 END) AS RegisteredOnlineToday
			, SUM(CASE WHEN CAST(C.[DateCreated] AS DATE) = CAST(Getdate() AS DATE)
						THEN 1 ELSE 0 END) AS RegisteredToday
			, (CASE WHEN UBC.TotalNumberUnpaid IS NULL 
					THEN 0 ELSE UBC.TotalNumberUnpaid END) AS NumberOfUnpaidCourses
			, (CASE WHEN UBC.TotalAmountUnpaid IS NULL 
					THEN 0 ELSE UBC.TotalAmountUnpaid END) AS TotalAmountUnpaid		
		FROM [dbo].[Organisation] O
		INNER JOIN [dbo].[ClientOrganisation] CO ON CO.[OrganisationId] = O.Id
		INNER JOIN [dbo].[Client] C ON C.Id = CO.[ClientId]
		LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.Id
		GROUP BY O.Id
				, O.Name
				, UBC.TotalNumberUnpaid
				, UBC.TotalAmountUnpaid
		;
		

		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.06_CreateView_vwDashboardMeter_Clients.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
