/*
 * SCRIPT: Alter Table NetcallErrorLog, Add new column RequestDate
 * Author: Robert Newnham
 * Created: 30/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_04.01_AmendTableNetcallErrorLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table NetcallErrorLog, Add new column RequestDate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.NetcallErrorLog
			ADD RequestDate DATETIME
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
