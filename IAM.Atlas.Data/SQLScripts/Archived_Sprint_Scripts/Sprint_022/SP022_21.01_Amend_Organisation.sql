/*
 * SCRIPT: Alter Table Organisation
 * Author: Dan Hough
 * Created: 30/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_21.01_Amend_Organisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to Organisation table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.Organisation
			ADD CreatedByUserId INT NULL
			, CONSTRAINT FK_Organisation_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;