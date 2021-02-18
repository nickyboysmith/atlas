/*
 * SCRIPT: 'Alter Table CourseDORSClient, Add new columns NumberOfDORSNotificationAttempts and DateDORSNotificationAttempted
 * Author: John Cocklin
 * Created: 11/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_27.01_AmendTableCourseDORSClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table CourseDORSClient, Add new columns NumberOfDORSNotificationAttempts and DateDORSNotificationAttempted';

IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDORSClient ADD
			NumberOfDORSNotificationAttempts	INT			NULL,
			DateDORSNotificationAttempted		DATETIME	NULL
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
