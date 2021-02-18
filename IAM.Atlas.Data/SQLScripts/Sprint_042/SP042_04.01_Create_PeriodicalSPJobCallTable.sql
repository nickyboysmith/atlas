/*
	SCRIPT: Create PeriodicalSPJobCall Table
	Author: Robert Newnham
	Created: 18/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_04.01_Create_PeriodicalSPJobCallTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PeriodicalSPJobCall Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PeriodicalSPJobCall'
		
		/*
		 *	Create PeriodicalSPJobCall Table
		 */
		IF OBJECT_ID('dbo.PeriodicalSPJobCall', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PeriodicalSPJobCall;
		END

		CREATE TABLE PeriodicalSPJobCall(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PeriodicalSPJobId INT NOT NULL
			, StoredProcedureName VARCHAR(400)
			, Comment VARCHAR(1000)
			, EventDateTime DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_PeriodicalSPJobCall_PeriodicalSPJob FOREIGN KEY (PeriodicalSPJobId) REFERENCES PeriodicalSPJob(Id)
			, INDEX IX_PeriodicalSPJobCallPeriodicalSPJobId NONCLUSTERED (PeriodicalSPJobId)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;