/*
	SCRIPT: Create NoteType Tables
	Author: Paul Tuck
	Created: 22/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_07.01_CreateTableNoteType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Used to filter Notes';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'NoteType'

		/*
			Create Table UserPreviousId
		*/
		IF OBJECT_ID('dbo.NoteType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NoteType;
		END

		CREATE TABLE NoteType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(25)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


