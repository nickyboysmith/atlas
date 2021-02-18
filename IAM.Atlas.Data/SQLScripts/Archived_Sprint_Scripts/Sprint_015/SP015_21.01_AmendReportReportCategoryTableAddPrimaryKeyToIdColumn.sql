/*
 * SCRIPT: Alter Table ReportsReportCategory Add Primary Key to Id Column
 * Author: Daniel Murray
 * Created: 05/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP015_21.01_AmendReportsReportCategoryTableAddPrimaryKeyToIdColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Primary Key to Id Column ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportsReportCategory
		ADD PRIMARY KEY (Id)
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

