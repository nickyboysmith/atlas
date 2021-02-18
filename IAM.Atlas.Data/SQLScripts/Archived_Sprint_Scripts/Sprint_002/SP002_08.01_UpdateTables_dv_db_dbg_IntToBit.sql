

/*
	SCRIPT: Update Dataviews, Dashboard and DashboardGroup tables
	Author: Nick Smith
	Created: 07/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_08.01_UpdateTables_dv_db_dbg_IntToBit.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Dataviews
		*/
		ALTER TABLE dbo.[Dataviews]
		ALTER COLUMN Enabled bit;
		/*
			Update Table Dashboard
		*/
		ALTER TABLE dbo.[Dashboard]
		ALTER COLUMN Enabled bit;
		/*
			Update Table DashboardGroup
		*/
		ALTER TABLE dbo.[DashboardGroup]
		ALTER COLUMN Enabled bit;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

