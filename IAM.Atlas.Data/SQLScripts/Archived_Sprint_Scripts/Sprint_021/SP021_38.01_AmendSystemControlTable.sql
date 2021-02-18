/*
 * SCRIPT: Alter Table SystemControl
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_38.01_AmendSystemControlTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns FeedbackName, FeedbackEmail to SystemControl table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.SystemControl
			ADD FeedbackName Varchar(320)
			,FeedbackEmail Varchar(320)
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;