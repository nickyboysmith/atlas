/*
	SCRIPT: Update "Note" Table
	Author: Paul Tuck
	Created: 22/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_08.01_UpdateNoteTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a NoteTypeId to the Note Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Note
		*/
		ALTER TABLE dbo.Note
		ADD NoteTypeId INT
		, CONSTRAINT FK_Note_NoteType FOREIGN KEY (NoteTypeId) REFERENCES Note(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
