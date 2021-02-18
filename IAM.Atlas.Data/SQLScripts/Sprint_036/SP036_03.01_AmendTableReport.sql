/*
 * SCRIPT: Add New Column to Table Report
 * Author: Robert Newnham
 * Created:07/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP036_03.01_AmendTableReport.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table Report';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[Report]
		ADD Landscape BIT NOT NULL DEFAULT 'False'
		, ChangeNo INT NOT NULL DEFAULT 1;
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;