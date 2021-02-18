/*
 * SCRIPT: Alter Table Document
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_33.01_AmendDocumentTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns FileSize, DocumentType to Document table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.Document
			ADD FileSize int
			,[Type] Varchar(10)
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;