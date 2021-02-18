/*
 * SCRIPT: Alter Table ClientDORSData Add Columns and Foreign Key
	Author: Paul Tuck
	Created: 14/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_07.01_AmendTableClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table ClientDORSData Add Columns and Foreign Key';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientDORSData
			ADD 
				  ExpiryDate DATETIME NULL
				, DORSSchemeId INT NOT NULL
				, DataValidatedAgainstDORS BIT DEFAULT 0 
				, CONSTRAINT FK_ClientDORSData_DORSScheme FOREIGN KEY (DORSSchemeId) REFERENCES [DORSScheme](Id)
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
