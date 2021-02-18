/*
	SCRIPT: Create TaskNote Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.05_Create_TaskNoteTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskNote Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskNote'
		
		/*
		 *	Create TaskNote Table
		 */
		IF OBJECT_ID('dbo.TaskNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskNote;
		END

		CREATE TABLE TaskNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, NoteId INT NOT NULL
			, CONSTRAINT FK_TaskNote_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			, INDEX IX_TaskNoteTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskNoteNoteId NONCLUSTERED (NoteId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;