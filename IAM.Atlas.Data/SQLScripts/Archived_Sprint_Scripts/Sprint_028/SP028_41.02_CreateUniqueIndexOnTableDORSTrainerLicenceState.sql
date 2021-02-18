
/*
 * SCRIPT: Create a Unique Index On Table DORSTrainerLicenceState
 * Author: Nick Smith
 * Created: 09/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_41.02_CreateUniqueIndexOnTableDORSTrainerLicenceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a Unique Index On Table DORSTrainerLicenceState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_DORSTrainerLicenceStateName' 
				AND object_id = OBJECT_ID('DORSTrainerLicenceState'))
		BEGIN
		   DROP INDEX [UX_DORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicenceState];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_DORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicenceState]
		(
			[Name]  ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

