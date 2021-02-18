/*
 * SCRIPT: Alter Table CourseDate - add in AttendanceVerified
 * Author: Dan Hough
 * Created: 31/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_14.01_AmendCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to CourseDate table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.CourseDate
		  ADD AttendanceVerified bit DEFAULT 'False' 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;