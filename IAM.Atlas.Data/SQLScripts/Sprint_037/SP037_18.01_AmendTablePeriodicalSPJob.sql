/*
 * SCRIPT: Amend/Add Column on Table PeriodicalSPJob
 * Author: Robert Newnham
 * Created: 09/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_18.01_AmendTablePeriodicalSPJob.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column on Table PeriodicalSPJob';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[PeriodicalSPJob]
		ADD DueDateTime DATETIME NOT NULL DEFAULT GETDATE();
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;