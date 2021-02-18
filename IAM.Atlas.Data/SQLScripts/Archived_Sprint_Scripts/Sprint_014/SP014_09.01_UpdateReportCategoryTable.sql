/*
	SCRIPT:  Update Report Category Table
	Author:  Dan Murray
	Created: 13/01/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_09.01_UpdateReportCategoryTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the Report Category table: add additional column Disabled';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update [ReportCategory] Table
		*/
		ALTER TABLE dbo.[ReportCategory] 
			ADD [Disabled] bit NULL DEFAULT 0;		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;