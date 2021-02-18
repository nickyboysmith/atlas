/*
 * SCRIPT: Alter Table Client, Add 7 new columns and 2 indexes.
 * Author: Nick Smith
 * Created: 15/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP016_04.01_AmendTableClientAdd7NewColumnsAnd2Indexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add 7 new columns and 2 Indexes to Client Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Client
		ADD DateCreated DateTime NOT NULL DEFAULT GetDate()
		, EmailCourseReminders bit DEFAULT 1
		, SMSCourseReminders bit DEFAULT 1
		, EmailedConfirmed bit DEFAULT 0
		, SMSConfirmed bit DEFAULT 0
		, EmailConfirmReference varchar(20) NULL 
		, SMSConfirmReference varchar(20) NULL 
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

