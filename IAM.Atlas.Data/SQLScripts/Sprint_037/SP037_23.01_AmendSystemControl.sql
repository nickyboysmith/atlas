/*
 * SCRIPT: Alter Table SystemControl
 * Author: Robert Newnham
 * Created: 11/05/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP037_23.01_AmendSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl 
		ADD
			ReportDefaultPageSize VARCHAR(20) NOT NULL DEFAULT 'A4'
			, ReportDefaultPageOrientation CHAR(1) NOT NULL DEFAULT 'P'
			, ReportDefaultPortraitRowsPerPage INT NOT NULL DEFAULT 25
			, ReportDefaultLanscapeRowsPerPage INT NOT NULL DEFAULT 20
			, ReportMaximumRows INT NOT NULL DEFAULT 4000

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
