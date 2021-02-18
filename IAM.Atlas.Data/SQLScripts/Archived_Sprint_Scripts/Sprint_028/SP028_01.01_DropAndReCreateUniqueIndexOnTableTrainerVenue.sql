/*
 * SCRIPT: Drop And ReCreate a Unique Index On Table TrainerVenue
 * Author: Nick Smith
 * Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_01.01_DropAndReCreateUniqueIndexOnTableTrainerVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop And ReCreate Unique Index On Table TrainerVenue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerVenueTrainerIdVenueId' 
				AND object_id = OBJECT_ID('TrainerVenue'))
		BEGIN
		   DROP INDEX [IX_TrainerVenueTrainerIdVenueId] ON [dbo].[TrainerVenue];
		END

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_TrainerVenueTrainerIdVenueId' 
				AND object_id = OBJECT_ID('TrainerVenue'))
		BEGIN
		   DROP INDEX [UX_TrainerVenueTrainerIdVenueId] ON [dbo].[TrainerVenue];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_TrainerVenueTrainerIdVenueId] ON [dbo].[TrainerVenue]
		(
			[TrainerId], [VenueId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

