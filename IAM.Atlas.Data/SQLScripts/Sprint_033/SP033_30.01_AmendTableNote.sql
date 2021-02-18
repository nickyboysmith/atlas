/*
 * SCRIPT: Change Defaults on Table Note
 * Author: Robert Newnham
 * Created: 17/02/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP033_30.01_AmendTableNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table Note';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.Note
		SET Removed = 'False'
		WHERE Removed IS NULL;

		ALTER TABLE dbo.Note
		ALTER COLUMN Removed BIT NOT NULL;

		ALTER TABLE dbo.Note 
		ADD CONSTRAINT DF_Note_Removed DEFAULT 'False' FOR Removed;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;