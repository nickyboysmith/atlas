/*
 * SCRIPT: Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_02.01_CorrectWronglyNamedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ScheduledSMSState'

		/*
		 *	Create ScheduledSMSStatus Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMSState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMSState;
		END

		CREATE TABLE ScheduledSMSState(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] varchar(100)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

