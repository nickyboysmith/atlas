/*
	SCRIPT: Drop constraint on Course to CourseLog
	Author: Dan Hough
	Created: 28/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_40.01_Drop_Constraint_CourseLog_Course.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop constraint on Course to CourseLog';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF OBJECT_ID('dbo.CourseLog', 'U') IS NOT NULL
		BEGIN
		
			/*Drop constraint on CourseLog*/
			IF EXISTS (SELECT * 
			  FROM sys.foreign_keys 
			   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseLog_Course')
			   AND parent_object_id = OBJECT_ID(N'dbo.CourseLog')
			)
			BEGIN
				ALTER TABLE dbo.CourseLog
				DROP CONSTRAINT FK_CourseLog_Course;
			END

		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;