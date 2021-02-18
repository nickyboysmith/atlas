/*
	SCRIPT:  Create TrainerBookingLimitationByMonth Table 
	Author: Dan Hough
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_15.01_Create_TrainerBookingLimitationByMonth.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerBookingLimitationByMonth Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerBookingLimitationByMonth'
		
		/*
		 *	Create TrainerBookingLimitationByMonth Table
		 */
		IF OBJECT_ID('dbo.TrainerBookingLimitationByMonth', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerBookingLimitationByMonth;
		END

		CREATE TABLE TrainerBookingLimitationByMonth(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, ForYear INT NOT NULL
			, ForMonth INT NOT NULL
			, Number INT
			, LastUpdated DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_TrainerBookingLimitationByMonth_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			);

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerBookingLimitationByMonth' 
			AND object_id = OBJECT_ID('dbo.TrainerBookingLimitationByMonth'))
		BEGIN
			DROP INDEX IX_TrainerBookingLimitationByMonth ON dbo.TrainerBookingLimitationByMonth;
		END
		
		CREATE UNIQUE INDEX IX_TrainerBookingLimitationByMonth ON dbo.TrainerBookingLimitationByMonth
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