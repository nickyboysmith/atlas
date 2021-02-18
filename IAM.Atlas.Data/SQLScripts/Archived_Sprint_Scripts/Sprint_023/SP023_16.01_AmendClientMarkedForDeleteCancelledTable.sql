/*
 * SCRIPT: Alter Table AmendClientMarkedForDeleteCancelled
 * Author: Nick Smith
 * Created: 15/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_16.01_AmendClientMarkedForDeleteCancelledTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column ClientMarkedForDeleteId and foreign key to ClientMarkedForDeleteCancelled table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.ClientMarkedForDeleteCancelled
			ADD ClientMarkedForDeleteId INT 
			, CONSTRAINT FK_ClientMarkedForDeleteCancelled_Client1 FOREIGN KEY (ClientMarkedForDeleteId) REFERENCES Client(Id)
			
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;