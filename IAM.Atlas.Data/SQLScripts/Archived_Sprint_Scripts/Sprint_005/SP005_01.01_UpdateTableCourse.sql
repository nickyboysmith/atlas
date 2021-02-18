/*
	SCRIPT: Update Table Course
	Author: Robert Newnham
	Created: 25/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_01.01_UpdateTableCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		ALTER TABLE dbo.Course
		ALTER COLUMN DefaultStartTime Varchar(5);
		
		ALTER TABLE dbo.Course
		ALTER COLUMN DefaultEndTime Varchar(5);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

