/*
 * SCRIPT: Alter Table ReportDataGridColumn Add new column and constraint for ReportDataGrid Table
 * Author: Daniel Murray
 * Created: 05/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP015_20.01_AmendReportDataGridColumnTableAddReportDataGridIdColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column ReportDataGridId to the ReportDataGridColumn Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportDataGridColumn
		ADD ReportDataGridId int NULL
		, CONSTRAINT FK_ReportDataGridColumn_ReportDataGrid FOREIGN KEY (ReportDataGridId) REFERENCES [ReportDataGrid](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

