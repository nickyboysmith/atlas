/*
	SCRIPT: Create TrainerAvailability Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_13.01_Create_TrainerAvailability.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerAvailability Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerAvailability'
		
		/*
		 *	Create TrainerAvailability Table
		 */
		IF OBJECT_ID('dbo.TrainerAvailability', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerAvailability;
		END

		CREATE TABLE TrainerAvailability(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT
			, AvailableForFutureBookings BIT DEFAULT 'True'
			, AvailableBetweenDates BIT DEFAULT 'False'
			, FirstAvailableDate DATETIME NULL
			, LastAvailableDate DATETIME NULL
			, CONSTRAINT FK_TrainerAvailability_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;