/*
	SCRIPT: Create a stored procedure to update set default Dashboard Meter assignments for User or All
	Author: Robert Newnham
	Created: 16/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_30.02_CreateSP_uspEnsureDefaultMeterAssignments.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update set default Dashboard Meter assignments for User or All';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspEnsureDefaultMeterAssignments', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspEnsureDefaultMeterAssignments;
	END		
	GO

	/*
		Create uspEnsureDefaultMeterAssignments
	*/

	CREATE PROCEDURE uspEnsureDefaultMeterAssignments (@UserId INT = NULL)
	AS
	BEGIN
	
		--ENSURE All Current System Administrators Have all Meters		
		INSERT INTO [dbo].[UserDashboardMeter] (UserId, DashboardMeterId)
		SELECT DISTINCT SAUDM.[UserId],SAUDM.[DashboardMeterId]
		FROM (SELECT DISTINCT SAU.[UserId], DM.Id AS [DashboardMeterId]
				FROM [DashboardMeter] DM
				, [dbo].[SystemAdminUser] SAU
				WHERE SAU.[UserId] = (CASE WHEN @UserId IS NULL THEN SAU.[UserId] ELSE @UserId END)
				) SAUDM
		INNER JOIN [DashboardMeter] DM2 ON DM2.Id = SAUDM.[DashboardMeterId]
		LEFT JOIN [dbo].[UserDashboardMeter] UDM ON UDM.[DashboardMeterId] = SAUDM.[DashboardMeterId]
												AND UDM.[UserId] = SAUDM.[UserId]
		WHERE UDM.Id IS NULL;
		
		--ENSURE All Current Organisation Administrators Have Certain Meters		
		INSERT INTO [dbo].[UserDashboardMeter] (UserId, DashboardMeterId)
		SELECT DISTINCT OAUDM.[UserId],OAUDM.[DashboardMeterId]
		FROM (SELECT DISTINCT OAU.[UserId], DM.Id AS [DashboardMeterId]
				FROM [DashboardMeter] DM
				, [dbo].[OrganisationAdminUser] OAU
				WHERE OAU.[UserId] = (CASE WHEN @UserId IS NULL THEN OAU.[UserId] ELSE @UserId END)
				) OAUDM
		INNER JOIN [DashboardMeter] DM2 ON DM2.Id = OAUDM.[DashboardMeterId]
		LEFT JOIN [dbo].[UserDashboardMeter] UDM ON UDM.[DashboardMeterId] = OAUDM.[DashboardMeterId]
												AND UDM.[UserId] = OAUDM.[UserId]
		WHERE UDM.Id IS NULL
		AND DM2.[AssignAllOrganisationAdmin] = 'True';
				
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP037_30.02_CreateSP_uspEnsureDefaultMeterAssignments.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO