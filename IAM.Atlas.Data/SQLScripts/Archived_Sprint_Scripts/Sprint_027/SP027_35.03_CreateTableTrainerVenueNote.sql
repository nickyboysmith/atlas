/*
 * SCRIPT: Create Table TrainerVenueNote 
 * Author: Nick Smith
 * Created: 17/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_35.03_CreateTableTrainerVenueNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table TrainerVenueNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVenueNote'
		
		/*
		 *	Create TrainerVenueNote Table
		 */
		IF OBJECT_ID('dbo.TrainerVenueNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVenueNote;
		END
		
		CREATE TABLE TrainerVenueNote(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [TrainerVenueId] INT NOT NULL
			, [NoteId] INT NOT NULL
			, CONSTRAINT FK_TrainerVenueNote_TrainerVenue FOREIGN KEY (TrainerVenueId) REFERENCES TrainerVenue(Id)
			, CONSTRAINT FK_TrainerVenueNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

