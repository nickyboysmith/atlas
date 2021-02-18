/*
 * SCRIPT: Create Table TrainerVenue
 * Author: Nick Smith
 * Created: 17/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_35.01_CreateTableTrainerVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table TrainerVenue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVenue'
		
		/*
		 *	Create TrainerVenue Table
		 */
		IF OBJECT_ID('dbo.TrainerVenue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVenue;
		END
		
		CREATE TABLE TrainerVenue(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [TrainerId] INT NOT NULL
			, [VenueId] INT NOT NULL
			, [DistanceHomeToVenueInMiles] FLOAT
			, [TrainerExcluded] BIT DEFAULT 'False'
			, [DateUpdated] DATETIME
			, [UpdatedByUserId] INT NOT NULL
			, CONSTRAINT FK_TrainerVenue_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_TrainerVenue_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			, CONSTRAINT FK_TrainerVenue_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		
		ALTER TABLE [dbo].[TrainerVenue] ADD CONSTRAINT DF_TrainerVenue_DateUpdated DEFAULT (GETDATE()) FOR [DateUpdated]
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

