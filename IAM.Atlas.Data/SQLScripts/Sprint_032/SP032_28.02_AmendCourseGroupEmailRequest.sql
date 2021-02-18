/*
 * SCRIPT: Alter Table CourseGroupEmailRequest
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_28.02_AmendCourseGroupEmailRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseGroupEmailRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseGroupEmailRequest 
		ADD
			ReadyToSend BIT NOT NULL DEFAULT 'True'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
