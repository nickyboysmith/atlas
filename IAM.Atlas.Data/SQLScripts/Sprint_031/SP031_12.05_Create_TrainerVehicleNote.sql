/*
	SCRIPT:  Create TrainerVehicleNote Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.05_Create_TrainerVehicleNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerVehicleNote Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVehicleNote'
		
		/*
		 *	Create TrainerVehicleNote Table
		 */
		IF OBJECT_ID('dbo.TrainerVehicleNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVehicleNote;
		END

		CREATE TABLE TrainerVehicleNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerVehicleId INT NOT NULL
			, NoteId INT NOT NULL
			, CONSTRAINT FK_TrainerVehicleNote_TrainerVehicle FOREIGN KEY (TrainerVehicleId) REFERENCES TrainerVehicle(Id)
			, CONSTRAINT FK_TrainerVehicleNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;