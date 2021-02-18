/*
 * SCRIPT: Make DateAddedToCourse and CourseClientId not null
 * Author: Dan Hough
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_06.01_AlterTableCourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Make DateAddedToCourse and CourseClientId not null';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientRemoved
		ALTER COLUMN DateAddedToCourse DATETIME NOT NULL;

		ALTER TABLE dbo.CourseClientRemoved
		ALTER COLUMN CourseClientId INT NOT NULL;


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
