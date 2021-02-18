/*
 * SCRIPT: Alter Table CourseClientTransferred, Add new columns Reason 
 * Author: Daniel Murray
 * Created: 05/10/2016  Amend Table, "CourseClientTransferred", add columns: "Reason" (400 chars)
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_12.01_AmendCourseClientTransferred.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table, "CourseClientTransferred", add columns: "Reason" (400 chars)';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientTransferred
			ADD Reason VARCHAR(400)
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
