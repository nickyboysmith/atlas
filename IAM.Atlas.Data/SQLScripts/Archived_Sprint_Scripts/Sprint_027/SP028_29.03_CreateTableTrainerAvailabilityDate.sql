/*
 * SCRIPT: Create TrainerAvailabilityDate Table
 * Author: Robert Newnham
 * Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_29.03_CreateTableTrainerAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerAvailabilityDate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerAvailabilityDate'
		
		/*
		 *	Create TrainerAvailabilityDate Table
		 */
		IF OBJECT_ID('dbo.TrainerAvailabilityDate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerAvailabilityDate;
		END
		
		CREATE TABLE TrainerAvailabilityDate(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [TrainerId] INT
			, [Date] DATETIME
			, [SessionNumber] INT
			, CONSTRAINT FK_TrainerAvailabilityDate_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

