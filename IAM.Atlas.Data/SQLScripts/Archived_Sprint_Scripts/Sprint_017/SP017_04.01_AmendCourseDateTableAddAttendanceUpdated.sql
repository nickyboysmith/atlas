/*
 * SCRIPT: Alter Table CourseDate Add new column AttendanceUpdated
 * Author: Dan Hough
 * Created: 04/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_04.01_AmendCourseDateTableAddAttendanceUpdated.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add AttendanceUpdated column to CourseDate table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.CourseDate
		ADD AttendanceUpdated bit DEFAULT 0;
		

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

