/*
	SCRIPT: Amend Table SystemAdminUser, Add Column
	Author: Robert Newnham
	Created: 12/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_14.01_AmendSystemAdminUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table SystemAdminUser, Add Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.SystemAdminUser 
		ADD
			CurrentlyProvidingSupport BIT NOT NULL DEFAULT 'True'


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END