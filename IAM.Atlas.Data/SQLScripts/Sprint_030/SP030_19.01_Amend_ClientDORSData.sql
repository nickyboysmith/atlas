/*
 * SCRIPT: Alter Table ClientDORSData Drop column OffenceDate if it exists
 * Author: Dan Hough
 * Created: 15/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_19.01_Amend_ClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table ClientDORSData Drop column OffenceDate if it exists';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF EXISTS(
				SELECT *
				FROM sys.columns 
				WHERE [Name] = N'OffenceDate'
				  AND Object_ID = Object_ID(N'dbo.ClientDORSData'))
		BEGIN
			ALTER TABLE dbo.ClientDORSData
			DROP COLUMN OffenceDate;
		END

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;