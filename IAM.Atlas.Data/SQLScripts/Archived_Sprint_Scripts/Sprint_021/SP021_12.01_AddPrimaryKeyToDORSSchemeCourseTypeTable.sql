/*
 * SCRIPT: Add Primary Key To DORSSchemeCourseType Table.
 * Author: Miles Stewart
 * Created: 02/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_12.01_AddPrimaryKeyToDORSSchemeCourseTypeTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Primary Key To DORSSchemeCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		TRUNCATE TABLE dbo.DORSSchemeCourseType;
			
		ALTER TABLE dbo.DORSSchemeCourseType
			ADD Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

