/*
 * SCRIPT: Amend Course Table Add Column
 * Author: Robert Newnham
 * Created: 14/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_12.01_AmendCourseTableAddColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Course Table Add Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.Course
			ADD LastBookingDate Datetime;
		
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;