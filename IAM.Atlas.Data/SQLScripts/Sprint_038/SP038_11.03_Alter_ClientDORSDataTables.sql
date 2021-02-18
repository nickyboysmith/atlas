/*
 * SCRIPT: Add new column to ClientDORSData
 * Author: Robert Newnham
 * Created: 26/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_11.03_Alter_ClientDORSDataTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column to ClientDORSData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientDORSData
		ADD IsMysteryShopper BIT NOT NULL DEFAULT 'False';
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
