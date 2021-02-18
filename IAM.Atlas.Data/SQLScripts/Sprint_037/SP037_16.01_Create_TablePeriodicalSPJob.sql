/*
	SCRIPT: Create PeriodicalSPJob Table 
	Author: Robert Newnham
	Created: 07/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_16.01_Create_TablePeriodicalSPJob.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PeriodicalSPJob Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PeriodicalSPJob'
		
		/*
		 *	Create PeriodicalSPJob Table
		 */
		IF OBJECT_ID('dbo.PeriodicalSPJob', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PeriodicalSPJob;
		END

		CREATE TABLE PeriodicalSPJob(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, StoredProcedureName VARCHAR(400) NOT NULL INDEX IX_PeriodicalSPJobStoredProcedureName NONCLUSTERED
			, DueDate DATE NOT NULL INDEX IX_PeriodicalSPJobDueDate NONCLUSTERED
			, DateLastRun DATETIME NULL
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, RunEveryAfterMinutes INT DEFAULT 0
			, RunAfterDays INT DEFAULT 0
			, RunAfterMonths INT DEFAULT 0
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;