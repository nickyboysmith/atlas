/*
 * SCRIPT: Alter Table AdministrationMenuItem Add New Columns
 * Author: Robert Newnham
 * Created: 19/11/2015
 */

DECLARE @ScriptName VARCHAR(100) = 'SP011_14.01_AdministrationMenuItemAddNewColumns.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to Table AdministrationMenuItem';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.AdministrationMenuItem
		ADD 
			Controller Varchar(40)
			, [Parameters] Varchar(100)
		;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

