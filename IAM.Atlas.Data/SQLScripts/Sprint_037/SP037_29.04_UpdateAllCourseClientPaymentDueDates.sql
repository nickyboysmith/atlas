/*
 * SCRIPT: Update All Course Client Payment Due Dates
 * Author: Robert Newnham
 * Created: 16/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_29.04_UpdateAllCourseClientPaymentDueDates.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update All Course Client Payment Due Dates';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC uspSetCoursePaymentDueDateIfRequired
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;