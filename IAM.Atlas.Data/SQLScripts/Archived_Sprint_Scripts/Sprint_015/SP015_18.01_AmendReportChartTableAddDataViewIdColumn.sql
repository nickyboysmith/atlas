/*
 * SCRIPT: Alter Table ReportChart Add new column and constraint for DataView Table
 * Author: Daniel Murray
 * Created: 05/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP015_18.01_AmendReportChartTableAddDataViewIdColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column DataViewId to the ReportChart Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportChart
		ADD DataViewId int NULL
		, CONSTRAINT FK_ReportChart_DataView FOREIGN KEY (DataViewId) REFERENCES [DataView](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

