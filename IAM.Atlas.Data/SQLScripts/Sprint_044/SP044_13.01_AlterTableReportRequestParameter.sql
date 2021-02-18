/*
 * SCRIPT: Alter ReportRequestParameter
 * Author: Robert Newnham
 * Created: 02/10/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_013.01_AlterTableReportRequestParameter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ReportRequestParameter';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportRequestParameter
		ADD ParameterValueText VARCHAR(400);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;