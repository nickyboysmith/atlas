/*
 * SCRIPT: Alter Table ReportChartColumn Add new column and constraint for ReportChart Table
 * Author: Daniel Murray
 * Created: 05/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP015_19.01_AmendReportChartColumnTableAddReportChartIdColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column ReportChartId to the ReportChartColumn Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportChart
		ADD PRIMARY KEY (Id)

		ALTER TABLE dbo.ReportChartColumn
		ADD ReportChartId int NULL
		, CONSTRAINT FK_ReportChartColumn_ReportChart FOREIGN KEY (ReportChartId) REFERENCES [ReportChart](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

