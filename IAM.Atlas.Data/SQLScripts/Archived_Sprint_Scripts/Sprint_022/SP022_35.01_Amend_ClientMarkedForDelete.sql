/*
 * SCRIPT: Alter Table ClientMarkedForDelete 
 * Author: Dan Hough
 * Created: 05/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_35.01_Amend_ClientMarkedForDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to ClientMarkedForDelete  table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientMarkedForDelete
			ADD CancelledByUserId  INT NULL
			, CONSTRAINT FK_ClientMarkedForDelete_User2 FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;