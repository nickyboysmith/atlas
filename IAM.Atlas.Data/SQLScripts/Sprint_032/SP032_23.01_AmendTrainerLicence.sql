/*
 * SCRIPT: Alter Table TrainerLicence
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_23.01_AmendTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to TrainerLicence Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.TrainerLicence 
		ADD
			LicenceCheckDue DateTime NULL

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
