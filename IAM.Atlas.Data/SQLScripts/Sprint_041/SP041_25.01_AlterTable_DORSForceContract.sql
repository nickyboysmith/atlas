/*
 * SCRIPT: Alter DORSForceContract
 * Author: Paul Tuck
 * Created: 01/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_25.01_AlterTable_DORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter DORSForceContract';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSForceContract
		ADD RegionId INT NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;