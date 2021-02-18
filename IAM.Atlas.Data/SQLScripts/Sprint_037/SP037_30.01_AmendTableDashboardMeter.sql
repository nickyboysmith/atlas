/*
 * SCRIPT: Add New Columns to Table DashboardMeter
 * Author: Robert Newnham
 * Created: 16/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_30.01_AmendTableDashboardMeter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table DashboardMeter';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DashboardMeter
		ADD AssignToAllSystemsAdmins BIT NOT NULL DEFAULT 'True'
		, AssignAllOrganisationAdmin BIT NOT NULL DEFAULT 'True'
		, AssignWholeOrganisation BIT NOT NULL DEFAULT 'False'
		, ExcludeReferringAuthorityOrganisation BIT NOT NULL DEFAULT 'True'
		, ExcludeTrainers BIT NOT NULL DEFAULT 'True';
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;