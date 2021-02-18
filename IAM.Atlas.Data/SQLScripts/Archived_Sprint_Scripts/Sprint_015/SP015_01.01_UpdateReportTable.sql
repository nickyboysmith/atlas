/*
	SCRIPT:  Update Report Table
	Author:  Dan Murray
	Created: 21/01/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_01.01_UpdateReportTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the Report table: add additional column AtlasSystemReport';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update [Report] Table
		*/
		ALTER TABLE dbo.[Report] 
			ADD [AtlasSystemReport] bit NULL DEFAULT 0;		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;