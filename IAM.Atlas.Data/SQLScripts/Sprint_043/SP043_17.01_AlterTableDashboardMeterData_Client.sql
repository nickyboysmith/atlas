/*
 * SCRIPT: Alter DashboardMeterData_Client
 * Author: Dan Hough
 * Created: 20/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP043_17.01_AlterTableDashboardMeterData_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter DashboardMeterData_Client';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DashboardMeterData_Client
		ADD ClientsWithMissingReferringAuthorityCreatedThisWeek INT NOT NULL DEFAULT ((0))
			, ClientsWithMissingReferringAuthorityCreatedThisMonth INT NOT NULL DEFAULT ((0))
			, ClientsWithMissingReferringAuthorityCreatedLastMonth INT NOT NULL DEFAULT ((0));

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;