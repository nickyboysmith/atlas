/*
	SCRIPT:  Create TrainerBookingSummary Table 
	Author: Dan Hough
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_15.03_Create_TrainerBookingSummary.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerBookingSummary Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerBookingSummary'
		
		/*
		 *	Create TrainerBookingSummary Table
		 */
		IF OBJECT_ID('dbo.TrainerBookingSummary', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerBookingSummary;
		END

		CREATE TABLE TrainerBookingSummary(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, ForYear INT NOT NULL
			, ForMonth INT NOT NULL
			, Booked INT NULL
			, Completed INT NULL
			, LastUpdated DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TrainerBookingSummary_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			);

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerBookingSummary' 
			AND object_id = OBJECT_ID('dbo.TrainerBookingSummary'))
		BEGIN
			DROP INDEX IX_TrainerBookingSummary ON dbo.TrainerBookingSummary;
		END
		
		CREATE UNIQUE INDEX IX_TrainerBookingSummary ON dbo.TrainerBookingSummary
		(
			TrainerId ASC
			, ForYear ASC
			, ForMonth ASC
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;