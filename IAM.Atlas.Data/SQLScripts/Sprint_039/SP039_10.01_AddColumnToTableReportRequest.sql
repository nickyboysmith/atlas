/*
	SCRIPT: Add Column To Table ReportRequest
	Author: Robert Newnham
	Created: 14/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_10.01_AddColumnToTableReportRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table ReportRequest';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportRequest 
		ADD SendToPrintQueue BIT NOT NULL DEFAULT 'False'
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END