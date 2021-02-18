/*
	SCRIPT: Create AnnualSPJob Table 
	Author: Dan Hough
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_16.01_Create_AnnualSPJob.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create AnnualSPJob Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'AnnualSPJob'
		
		/*
		 *	Create AnnualSPJob Table
		 */
		IF OBJECT_ID('dbo.AnnualSPJob', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AnnualSPJob;
		END

		CREATE TABLE AnnualSPJob(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, StoredProcedureName VARCHAR(400) NOT NULL
			, DueDate DATE NOT NULL
			, DateLastRun DATETIME NULL
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			);

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_AnnualSPJob' 
			AND object_id = OBJECT_ID('dbo.AnnualSPJob'))
		BEGIN
			DROP INDEX IX_AnnualSPJob ON dbo.AnnualSPJob;
		END
		
		CREATE UNIQUE INDEX IX_AnnualSPJob ON dbo.AnnualSPJob
		(
			StoredProcedureName ASC
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;