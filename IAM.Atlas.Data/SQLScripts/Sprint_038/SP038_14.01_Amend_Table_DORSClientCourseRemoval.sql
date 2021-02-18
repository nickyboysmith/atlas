/*
 * SCRIPT: Add New Columns to Table DORSClientCourseRemoval
 * Author: Paul Tuck
 * Created: 31/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_13.01_Amend_Table_DORSClientCourseRemoval.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table DORSClientCourseRemoval';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSClientCourseRemoval
		ADD IsMysteryShopper BIT NOT NULL Default 'False',
		DateDORSNotificationAttempted DateTime NULL,
		NumberOfDORSNotificationAttempts INT NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;