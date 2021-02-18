/*
	SCRIPT: Add Column To Table TrainerLicence
	Author: Robert Newnham
	Created: 12/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_04.01_AddColumnToTableTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table TrainerLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.TrainerLicence 
		ADD DateCreated DATETIME NOT NULL DEFAULT GETDATE();
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END