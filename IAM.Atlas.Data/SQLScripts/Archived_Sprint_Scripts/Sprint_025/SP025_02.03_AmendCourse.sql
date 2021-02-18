/*
 * SCRIPT: Alter Table Course
 * Author: Robert Newnham
 * Created: 19/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP025_02.03_AmendCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
			ADD AttendanceCheckRequired bit DEFAULT 'True'
			, DateAttendanceSentToDORS DateTime
			, AttendanceSentToDORS bit DEFAULT 'False'
			, AttendanceCheckVerified bit DEFAULT 'False'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
