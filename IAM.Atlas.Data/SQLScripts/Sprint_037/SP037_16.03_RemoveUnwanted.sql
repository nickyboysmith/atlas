/*
	SCRIPT: Remove Unneeded Stored Procedure and Table
	Author: Robert Newnham
	Created: 07/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_16.03_RemoveUnwanted.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Unneeded Stored Procedure and Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'AnnualSPJob'
		
		/*
		 *	Remove PeriodicalSPJob Table
		 */
		IF OBJECT_ID('dbo.AnnualSPJob', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AnnualSPJob;
		END
			
		IF OBJECT_ID('dbo.uspRunAnnualStoredProcedures', 'P') IS NOT NULL
		BEGIN
			DROP PROCEDURE dbo.uspRunAnnualStoredProcedures;
		END	

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;