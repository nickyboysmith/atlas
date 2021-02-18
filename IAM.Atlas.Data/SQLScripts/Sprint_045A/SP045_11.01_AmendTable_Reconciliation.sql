/*
	SCRIPT: Alter Reconciliation Table
	Author: Dan Hough
	Created: 03/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_11.01_AmendTable_Reconciliation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Reconciliation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Reconciliation
		ADD [Name] VARCHAR(100);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
