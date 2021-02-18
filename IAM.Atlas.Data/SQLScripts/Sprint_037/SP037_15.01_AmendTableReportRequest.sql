/*
 * SCRIPT: Add Missing Column to Table DashboardMeterData_Course
 * Author: Robert Newnham
 * Created: 07/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_15.01_AmendTableDashboardMeterData_Course.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Column to Table DashboardMeterData_Course';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DashboardMeterData_Course
		ADD NumberOfUnpaidCourses INT NOT NULL DEFAULT 0
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;