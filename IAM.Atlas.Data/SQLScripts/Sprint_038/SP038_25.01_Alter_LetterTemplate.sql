/*
 * SCRIPT: Add Column IdKeyName to LetterCategory table
 * Author: Dan Hough
 * Created: 06/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_25.01_Alter_LetterTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column IdKeyName to LetterCategory table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.LetterCategory
		ADD IdKeyName VARCHAR(100) NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;