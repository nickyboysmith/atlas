/*
	SCRIPT: Create SchedulerControlNote Table
	Author: Robert Newnham
	Created: 17/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.04_Create_SchedulerControlNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the SchedulerControlNote Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SchedulerControlNote'
		
		/*
		 *	Create SchedulerControlNote Table
		 */
		IF OBJECT_ID('dbo.SchedulerControlNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SchedulerControlNote;
		END

		CREATE TABLE SchedulerControlNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, NoteId int NOT NULL
			, CONSTRAINT FK_SchedulerControlNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;