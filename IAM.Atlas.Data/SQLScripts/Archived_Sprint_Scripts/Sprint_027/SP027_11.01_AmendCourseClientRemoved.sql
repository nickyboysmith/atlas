/*
 * SCRIPT: Alter Table CourseClientRemoved, Add new columns Reason and DORSOfferWithdrawn
 * Author: Daniel Murray
 * Created: 05/10/2016  Amend Table, "CourseClientRemoved", add columns: "Reason" (400 chars), DORSOfferWithdrawn (Default to False)
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_11.01_AmendCourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table, "CourseClientRemoved", add columns: "Reason" (400 chars), DORSOfferWithdrawn (Default to False)';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientRemoved
			ADD Reason VARCHAR(400),
			 DORSOfferWithdrawn BIT DEFAULT 0
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
