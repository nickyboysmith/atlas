/*
	SCRIPT: Update Table Course
	Author: Miles Stewart
	Created: 05/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_03.01_UpdateTheCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a column to the Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		ALTER TABLE dbo.Course
		ADD Reference Varchar(100);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
