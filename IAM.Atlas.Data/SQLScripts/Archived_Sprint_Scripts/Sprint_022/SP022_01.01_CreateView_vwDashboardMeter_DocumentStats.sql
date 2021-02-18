/*
	SCRIPT: Create a Dashboard Meter View for Documents
	Author: Dan Murray
	Created: 16/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_01.01_CreateView_vwDashboardMeter_DocumentStats.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_Documents';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_DocumentStats', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_DocumentStats;
	END		
	GO

	/*
		Create View vwDashboardMeter_DocumentStats
	*/
	CREATE VIEW vwDashboardMeter_DocumentStats AS	
				SELECT 
				30 AS OrganisationId				
				, 400 AS NumDocumentsinSystem
				, 20 AS TotDocSizeintheSysteminGB
				, 300 AS NumDocAddThisMonth
				, 2 AS TotDocSizeAddThisMonthinGB
				, 15 AS NumDocAddPrevMonth
				, 54 AS TotDocSizeAddPrevinGB
				, 87 AS NumDocAddThisYr
				, 98 AS TotDocSizeAddThisYrinGB
				, 75 AS NumDocAddPrevYr
				, 45 AS TotDocSizeAddPrevYrinGB
				, 96 AS NumDocAddYrtwoyrsago
				, 78 AS TotDocSizeAddYrtwoyrsagoinGB
				, 45 AS NumDocAddYr3yrsago
				, 33 AS TotDocSizeAddYr3yrsagoinGB
				
				UNION
				SELECT
				1 AS OrganisationId				
				, 400 AS NumDocumentsinSystem
				, 20 AS TotDocSizeintheSysteminGB
				, 300 AS NumDocAddThisMonth
				, 2 AS TotDocSizeAddThisMonthinGB
				, 15 AS NumDocAddPrevMonth
				, 54 AS TotDocSizeAddPrevinGB
				, 87 AS NumDocAddThisYr
				, 98 AS TotDocSizeAddThisYrinGB
				, 75 AS NumDocAddPrevYr
				, 45 AS TotDocSizeAddPrevYrinGB
				, 96 AS NumDocAddYrtwoyrsago
				, 78 AS TotDocSizeAddYrtwoyrsagoinGB
				, 45 AS NumDocAddYr3yrsago
				, 33 AS TotDocSizeAddYr3yrsagoinGB
				
				UNION
				SELECT
				12 AS OrganisationId				
				, 400 AS NumDocumentsinSystem
				, 20 AS TotDocSizeintheSysteminGB
				, 300 AS NumDocAddThisMonth
				, 2 AS TotDocSizeAddThisMonthinGB
				, 15 AS NumDocAddPrevMonth
				, 54 AS TotDocSizeAddPrevinGB
				, 87 AS NumDocAddThisYr
				, 98 AS TotDocSizeAddThisYrinGB
				, 75 AS NumDocAddPrevYr
				, 45 AS TotDocSizeAddPrevYrinGB
				, 96 AS NumDocAddYrtwoyrsago
				, 78 AS TotDocSizeAddYrtwoyrsagoinGB
				, 45 AS NumDocAddYr3yrsago
				, 33 AS TotDocSizeAddYr3yrsagoinGB
				
				
				
		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_01.01_CreateView_vwDashboardMeter_DocumentStats.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
