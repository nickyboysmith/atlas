/*
	SCRIPT:  Update Report Chart Table
	Author:  Dan Murray
	Created: 21/01/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_02.01_UpdateReportChartTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the Report Chart table: amend size of column ChartType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update [ReportChart] Table
		*/
		ALTER TABLE dbo.[ReportChart] 
			ALTER COLUMN ChartType VARCHAR(100) NULL;		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;