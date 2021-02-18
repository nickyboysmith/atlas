
/*
	SCRIPT: Alter Table Column Sizes
	Author: Robert Newnham
	Created: 28/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_26.03_CreateTrainerDatesTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'TrainerDatesUnavailable'
			EXEC dbo.uspDropTableContraints 'TrainerWeekDaysAvailable'

		/*
			Create Table TrainerDatesUnavailable
		*/
		IF OBJECT_ID('dbo.TrainerDatesUnavailable', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerDatesUnavailable;
		END

		CREATE TABLE TrainerDatesUnavailable(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL 
			, StartDate DATETIME 
			, EndDate DATETIME 
			, AllDay bit
			, StartTime DATETIME 
			, EndTime DATETIME 
			, UpdatedByUserId INT NOT NULL
			, Removed bit
			, CONSTRAINT FK_TrainerDatesUnavailable_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
			, CONSTRAINT FK_TrainerDatesUnavailable_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)					
		);

		/*
			Create Table TrainerWeekDaysAvailable
		*/
		IF OBJECT_ID('dbo.TrainerWeekDaysAvailable', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerWeekDaysAvailable;
		END

		CREATE TABLE TrainerWeekDaysAvailable(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL 
			, WeekDayNumber INT NOT NULL 
			, UpdatedByUserId INT NOT NULL
			, Removed bit
			, CONSTRAINT FK_TrainerWeekDaysAvailable_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
			, CONSTRAINT FK_TrainerWeekDaysAvailable_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)					
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

