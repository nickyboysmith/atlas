/*
 * SCRIPT: Alter Table CourseDate Add new column AttendanceUpdated
 * Author: Paul Tuck
 * Created: 09/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_05.01_Amend_OrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Active column to Organisation table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Organisation
		ADD Active bit DEFAULT 0;
		

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

