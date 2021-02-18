/*
	SCRIPT: Create Table TrainerPreviousId
	Author: Robert Newnham
	Created: 20/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_14.03_CreateTableTrainerPreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table TrainerPreviousId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerPreviousId'
		
		/*
		 *	Create TrainerPreviousId Table
		 */
		IF OBJECT_ID('dbo.TrainerPreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerPreviousId;
		END

		CREATE TABLE TrainerPreviousId(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL INDEX IX_TrainerPreviousIdTrainerId NONCLUSTERED
			, PreviousTrainerId INT NOT NULL INDEX IX_TrainerPreviousIdPreviousTrainerId NONCLUSTERED
			, DateAdded DateTime NOT NULL DEFAULT GETDATE()
			, PreviousOrgId INT NULL
			, PreviousRgnId INT NULL
			, CONSTRAINT FK_TrainerPreviousId_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
		);
			
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END