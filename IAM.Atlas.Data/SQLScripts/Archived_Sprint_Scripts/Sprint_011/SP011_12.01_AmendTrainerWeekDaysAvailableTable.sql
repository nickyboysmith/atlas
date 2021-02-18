/*
 * SCRIPT: Add date field to the TrainerWeekDaysAvailable table
 * Author: Miles Stewart
 * Created: 11/11/2015
 */
DECLARE @ScriptName VARCHAR(100) = 'SP011_12.01_AmendTrainerWeekDaysAvailableTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add date field to the TrainerWeekDaysAvailable table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Amend TrainerWeekDaysAvailable Table
		 */
		ALTER TABLE dbo.TrainerWeekDaysAvailable ADD DateCreated Datetime;
		ALTER TABLE dbo.TrainerWeekDaysAvailable 
			ADD DEFAULT CURRENT_TIMESTAMP FOR DateCreated; 					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;