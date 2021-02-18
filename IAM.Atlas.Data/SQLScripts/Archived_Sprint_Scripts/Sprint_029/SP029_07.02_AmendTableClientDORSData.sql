/*
 * SCRIPT: Alter Table ClientDORSData fix not null column 
	Author: Paul Tuck
	Created: 14/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_07.02_AmendTableClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table ClientDORSData Add Columns and Foreign Key';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.ClientDORSData SET DORSSchemeId = -1 WHERE DORSSchemeId = NULL;

		ALTER TABLE dbo.ClientDORSData
			ALTER COLUMN 
				DORSSchemeId INT NOT NULL
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
