/*
 * SCRIPT: Amend Table ReportDataGridColumn, Add Sort Order column.
 * Author: Paul Tuck
 * Created: 24/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP016_09.01_Amend_ReportDataGridColumnTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table ReportDataGridColumn, Add Sort Order column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.ReportDataGridColumn
		ADD
			SortOrder int NULL		
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

