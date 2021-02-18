/*
	SCRIPT: Update Note Table Set NoteTypeId To General Where NoteTypeId IS NULL
	Author: Paul Tuck
	Created: 27/09/2018
*/

DECLARE @ScriptName VARCHAR(100) = 'SP044_09.02_Update_Note_Table_Set_NoteTypeId_Where_NULL';
DECLARE @ScriptComments VARCHAR(800) = 'Update Note Table Set NoteTypeId To General Where NoteTypeId IS NULL';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	DECLARE @generalNoteTypeId INT;
	
	SELECT @generalNoteTypeId = Id FROM NoteType WHERE Name = 'General';

	UPDATE Note 
	SET NoteTypeId = @generalNoteTypeId 
	WHERE notetypeid is null
	AND LTRIM(RTRIM(Note)) != '';


GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP044_09.02_Update_Note_Table_Set_NoteTypeId_Where_NULL';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO