/*
	SCRIPT: Remove DORSTrainerStatus Table
	Author: Robert Newnham
	Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_03.03_Remove_DORSTrainerStatus.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove DORSTrainerStatus Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerStatus'
		
		/*
		 *	Remove DORSTrainerStatus Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerStatus', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerStatus;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;