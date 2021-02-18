
/*
	SCRIPT: Create a view to list meters available by User within Organisations
	Author: Nick Smith
	Created: 05/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_23.01_CreateView_vwDashboardMeter_UserAccess.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to list meters available by User within Organisations';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_UserAccess', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_UserAccess;
	END		
	GO

	/*
		Create View vwDashboardMeter_UserAccess
	*/
		CREATE VIEW dbo.vwDashboardMeter_UserAccess AS	
	
			SELECT o.Id AS OrganisationId
					,o.Name AS OrganisationName
					,u.Id AS UserId
					,u.Name AS UserDisplayName
					,dm.Id AS Id
					,dm.Name AS Name
					,dm.Title AS Title
					,dm.[Description] AS [Description]
					,dm.RefreshRate AS RefreshRate
			FROM DashboardMeter dm
					INNER JOIN OrganisationDashboardMeter odm ON odm.DashboardMeterId = dm.Id 	
					INNER JOIN OrganisationUser ou ON ou.OrganisationId = odm.OrganisationId
					INNER JOIN Organisation o ON o.Id = odm.Id
					INNER JOIN [User] u ON u.Id = ou.UserId
			WHERE u.[Disabled] = 'False' AND dm.[Disabled] = 'False'  
			UNION SELECT
					NULL AS OrganisationId
					,NULL AS OrganisationName
					,u.Id AS UserId
					,u.Name AS UserDisplayName
					,dm.Id AS Id
					,dm.Name AS Name
					,dm.Title AS Title
					,dm.[Description] AS [Description]
					,dm.RefreshRate AS RefreshRate
			FROM DashboardMeter dm
					INNER JOIN UserDashboardMeter udm ON udm.DashboardMeterId = dm.Id 	
					INNER JOIN [User] u ON u.Id = udm.UserId
			WHERE u.[Disabled] = 'False' AND dm.[Disabled] = 'False'  
			
		GO	

DECLARE @ScriptName VARCHAR(100) = 'SP024_23.01_CreateView_vwDashboardMeter_UserAccess.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO



