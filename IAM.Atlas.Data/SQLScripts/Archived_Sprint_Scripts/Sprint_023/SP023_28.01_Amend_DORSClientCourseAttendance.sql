/*
 * SCRIPT: Alter Table DORSClientCourseAttendance 
 * Author: Dan Hough
 * Created: 22/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_28.01_Amend_DORSClientCourseAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to DORSClientCourseAttendance  table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSClientCourseAttendance
			ADD DORSAttendanceStateId INT NULL

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
