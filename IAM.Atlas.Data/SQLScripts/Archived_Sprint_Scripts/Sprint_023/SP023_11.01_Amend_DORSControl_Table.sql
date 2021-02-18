/*
 * SCRIPT: Alter Table DORSControl
 * Author: Nick Smith
 * Created: 12/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_11.01_Amend_DORSControl_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column MaximumPostsPerSession to DORSControl table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.DORSControl
			ADD MaximumPostsPerSession INT DEFAULT 100;
			
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;