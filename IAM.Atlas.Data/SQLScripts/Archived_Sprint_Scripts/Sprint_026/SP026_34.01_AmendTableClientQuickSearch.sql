/*
 * SCRIPT: Alter Table ClientQuickSearch, Add new column DateRefreshed
 * Author: Robert Newnham
 * Created: 26/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_34.01_AmendTableClientQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table ClientQuickSearch, Add new column DateRefreshed';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientQuickSearch
			ADD DateRefreshed DATETIME DEFAULT GETDATE()
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
