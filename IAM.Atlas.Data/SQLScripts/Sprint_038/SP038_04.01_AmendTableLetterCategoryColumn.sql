/*
 * SCRIPT: Add New Column to Table LetterCategoryColumn
 * Author: Robert Newnham
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_04.01_AmendTableLetterCategoryColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table LetterCategoryColumn';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.LetterCategoryColumn
		ADD TagName VARCHAR(100) NOT NULL
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;