/*
 * SCRIPT: Add Date Created To DORSSchemeCourseType Table.
 * Author: Miles Stewart
 * Created: 02/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_11.01_AddDateCreatedToDORSSchemeCourseTypeTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Date Created To DORSSchemeCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		ALTER TABLE dbo.DORSSchemeCourseType
			ADD DateCreated DATETIME DEFAULT GETDATE();
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

