/*
	SCRIPT: Alter the ScheduledEmail Table to add a Subject column
	Author: Miles Stewart
	Created: 09/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_25.01_AlterScheduledEmailTableToAddSubjectColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter the ScheduledEmail Table to add a Subject column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/**
		 * Add Subject Column to the table
		 */
		ALTER TABLE dbo.ScheduledEmail
			ADD [Subject] varchar(320);



		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;