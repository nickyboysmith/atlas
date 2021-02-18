/*
 * SCRIPT: Add new column to LetterTemplate
 * Author: Dan Hough
 * Created: 01/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_18.02_Alter_LetterTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column to LetterTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.LetterTemplate
		ADD IdKeyName VARCHAR(100) NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;