/*
	SCRIPT: Create TrainerAvailabilityByMonth Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_12.01_Create_TrainerAvailabilityByMonth.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerAvailabilityByMonth Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerAvailabilityByMonth'
		
		/*
		 *	Create TrainerAvailabilityByMonth Table
		 */
		IF OBJECT_ID('dbo.TrainerAvailabilityByMonth', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerAvailabilityByMonth;
		END

		CREATE TABLE TrainerAvailabilityByMonth(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT
			, CalendarYear INT
			, CalendarMonth INT
			, Available BIT DEFAULT 'True'
			, EveryDay BIT DEFAULT 'False'
			, BankHolidays BIT DEFAULT 'False'
			, Weekends BIT DEFAULT 'False'
			, WeekDays BIT DEFAULT 'True'
			, TheSameForFutureMonths BIT DEFAULT 'True'
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, Note VARCHAR(100)
			, CONSTRAINT FK_TrainerAvailabilityByMonth_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_TrainerAvailabilityByMonth_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;