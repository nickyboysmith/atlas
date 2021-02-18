/*
 * SCRIPT: Alter TrainerAvailabilityDate - change Date column from DateTime to Date
 * Author: Dan Hough
 * Created: 13/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_16.01_Amend_TrainerAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter TrainerAvailabilityDate - change Date column from DateTime to Date';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerAvailabilityDateDate' 
			AND object_id = OBJECT_ID('dbo.TrainerAvailabilityDate'))
		BEGIN
			DROP INDEX IX_TrainerAvailabilityDateDate ON dbo.TrainerAvailabilityDate;
		END

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerAvailabilityDateTrainerIdDate' 
			AND object_id = OBJECT_ID('dbo.TrainerAvailabilityDate'))
		BEGIN
			DROP INDEX IX_TrainerAvailabilityDateTrainerIdDate ON dbo.TrainerAvailabilityDate;
		END

		ALTER TABLE dbo.TrainerAvailabilityDate
		ALTER COLUMN [Date] DATE;

		CREATE NONCLUSTERED INDEX [IX_TrainerAvailabilityDateDate] ON [dbo].[TrainerAvailabilityDate]
		(
			[Date] ASC
		)

		CREATE NONCLUSTERED INDEX [IX_TrainerAvailabilityDateTrainerIdDate] ON [dbo].[TrainerAvailabilityDate]
		(
			[TrainerId] ASC,
			[Date] ASC
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
