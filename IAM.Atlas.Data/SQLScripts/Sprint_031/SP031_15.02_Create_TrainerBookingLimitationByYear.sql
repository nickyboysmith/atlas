/*
	SCRIPT:  Create TrainerBookingLimitationByYear Table 
	Author: Dan Hough
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_15.02_Create_TrainerBookingLimitationByYear.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerBookingLimitationByYear Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerBookingLimitationByYear'
		
		/*
		 *	Create TrainerBookingLimitationByYear Table
		 */
		IF OBJECT_ID('dbo.TrainerBookingLimitationByYear', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerBookingLimitationByYear;
		END

		CREATE TABLE TrainerBookingLimitationByYear(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, ForYear INT NOT NULL
			, ForMonth INT NOT NULL
			, Number INT
			, LastUpdated DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TrainerBookingLimitationByYear_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			);

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerBookingLimitationByYear' 
			AND object_id = OBJECT_ID('dbo.TrainerBookingLimitationByYear'))
		BEGIN
			DROP INDEX IX_TrainerBookingLimitationByYear ON dbo.TrainerBookingLimitationByYear;
		END
		
		CREATE UNIQUE INDEX IX_TrainerBookingLimitationByYear ON dbo.TrainerBookingLimitationByYear
		(
			TrainerId ASC
			, ForYear ASC
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;