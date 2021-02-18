


/*
	SCRIPT: Update Table CourseType
	Author: Robert Newnham
	Created: 19/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_04.01_UpdateTableCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table CourseType
		*/
		ALTER TABLE dbo.CourseType
		ALTER COLUMN Title Varchar(200);
		
		ALTER TABLE dbo.CourseType
		ALTER COLUMN Code Varchar(20);

		ALTER TABLE dbo.CourseType
		ALTER COLUMN [Description] Varchar(1000);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

