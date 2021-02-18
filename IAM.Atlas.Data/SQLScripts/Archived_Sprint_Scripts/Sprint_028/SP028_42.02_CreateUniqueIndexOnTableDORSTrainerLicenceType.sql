
/*
 * SCRIPT: Create a Unique Index On Table DORSTrainerLicenceType
 * Author: Nick Smith
 * Created: 09/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_42.02_CreateUniqueIndexOnTableDORSTrainerLicenceType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a Unique Index On Table DORSTrainerLicenceType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_DORSTrainerLicenceTypeName' 
				AND object_id = OBJECT_ID('DORSTrainerLicenceType'))
		BEGIN
		   DROP INDEX [UX_DORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicenceType];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_DORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicenceType]
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

