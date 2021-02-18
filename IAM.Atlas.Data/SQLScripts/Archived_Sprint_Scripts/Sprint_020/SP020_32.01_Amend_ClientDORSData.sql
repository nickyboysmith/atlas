/*
 * SCRIPT: Alter Table ClientDORSData
 * Author: Dan Hough
 * Created: 16/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_32.01_Amend_ClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to ClientDORSData table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.ClientDORSData
			ADD OffenceDate datetime NULL

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;