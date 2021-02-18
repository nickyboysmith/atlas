/*
	SCRIPT: Update Rename Course Dates table
	Author: Miles Stewart
	Created: 03/07/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP005_02.01_UpdateRenameCourseDatesTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename the Course Dates table from plural to singular';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		IF OBJECT_ID('dbo.CourseDates', 'U') IS NOT NULL
		BEGIN
			EXEC sp_rename 'dbo.CourseDates', 'CourseDate', 'Object';
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;