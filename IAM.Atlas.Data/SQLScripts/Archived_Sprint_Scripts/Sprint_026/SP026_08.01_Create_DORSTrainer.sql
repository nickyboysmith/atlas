/*
	SCRIPT: Create DORSTrainer Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_08.01_Create_DORSTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSTrainer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainer'
		
		/*
		 *	Create DORSTrainer Table
		 */
		IF OBJECT_ID('dbo.DORSTrainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainer;
		END

		CREATE TABLE DORSTrainer(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, DORSTrainerIdentifier VARCHAR(40)
			, CONSTRAINT FK_DORSTrainer_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_DORSTrainer_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;