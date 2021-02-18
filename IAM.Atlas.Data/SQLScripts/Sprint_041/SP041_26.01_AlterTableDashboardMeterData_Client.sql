/*
 * SCRIPT: Alter DashboardMeterData_Client
 * Author: Nick Smith
 * Created: 02/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_26.01_AlterTableDashboardMeterData_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter DashboardMeterData_Client';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DashboardMeterData_Client
		ADD UnableToUpdateInDORS INT NOT NULL DEFAULT ((0));

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
