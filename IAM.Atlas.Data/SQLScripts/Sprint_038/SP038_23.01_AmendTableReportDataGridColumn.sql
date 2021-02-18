/*
 * SCRIPT: Add New Column to Table ReportDataGridColumn
 * Author: Robert Newnham
 * Created: 05/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_23.01_AmendTableReportDataGridColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table ReportDataGridColumn';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportDataGridColumn
		ADD ColumnTitle VARCHAR(100) NULL
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;