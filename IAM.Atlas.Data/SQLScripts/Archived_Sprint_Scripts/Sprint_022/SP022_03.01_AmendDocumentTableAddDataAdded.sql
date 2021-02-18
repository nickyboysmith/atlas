/*
 * SCRIPT: Alter Table Users
 * Author: Nick Smith
 * Created: 17/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_03.01_AmendDocumentTableAddDataAdded.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add DateAdded column to Document table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF NOT EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'DateAdded' 
					AND Object_ID = Object_ID(N'Document'))
		BEGIN
			ALTER TABLE dbo.[Document]
				ADD DateAdded DateTime DEFAULT GETDATE()
		END
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;