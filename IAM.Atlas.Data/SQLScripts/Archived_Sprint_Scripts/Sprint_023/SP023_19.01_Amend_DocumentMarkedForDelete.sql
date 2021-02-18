/*
 * SCRIPT: Alter Table DocumentMarkedForDelete 
 * Author: Nick Smith
 * Created: 15/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_19.01_Amend_DocumentMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column CancelledByUserId to DocumentMarkedForDelete table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DocumentMarkedForDelete
			ADD CancelledByUserId  INT NULL
			, CONSTRAINT FK_DocumentMarkedForDelete_User1 FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;