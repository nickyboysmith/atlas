


/*
	SCRIPT: Update Table CourseCategory
	Author: Robert Newnham
	Created: 19/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_06.01_UpdateTableCourseCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table CourseCategory
		*/
		ALTER TABLE dbo.CourseCategory
		ALTER COLUMN Name Varchar(100);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

