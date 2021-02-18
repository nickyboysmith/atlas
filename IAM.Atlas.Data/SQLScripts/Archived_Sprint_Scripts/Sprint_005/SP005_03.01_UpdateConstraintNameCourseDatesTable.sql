/*
	SCRIPT: Update the name of the constraint
	Author: Miles Stewart
	Created: 03/07/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP005_03.01_UpdateConstraintNameCourseDatesTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename the Course Dates constraint';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		/*
			Update Table Course Constraint
		*/
		IF OBJECT_ID('dbo.CourseDate', 'U') IS NOT NULL
		BEGIN
			EXEC sp_rename 'dbo.FK_CourseDates_Course', 'FK_CourseDate';
		END

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;