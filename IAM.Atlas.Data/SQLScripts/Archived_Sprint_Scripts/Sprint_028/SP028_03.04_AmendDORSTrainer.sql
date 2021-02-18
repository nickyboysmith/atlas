/*
 * SCRIPT: Alter Table DORSTrainer Add Columns
	Author: Robert Newnham
	Created: 20/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_03.04_AmendDORSTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table DORSTrainer Add Columns';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSTrainer
			ADD 
				LicenceCode VARCHAR(100)
				, DORSLicenceExpiry DATE
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
