/*
 * SCRIPT: Alter Table Course, Add new columns 
 * Author: Robert Newnham
 * Created: 16/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_25.02_AmendTableCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Course, Add new columns ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
			ADD DORSCourse BIT DEFAULT 'False'
			, DORSNotificationRequested BIT DEFAULT 'False'
			, DORSNotified BIT DEFAULT 'False'
			, DateDORSNotified DATETIME
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
