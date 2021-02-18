
/*
 * SCRIPT: Create Unique And Single Indexs On Table DORSTrainerLicence
 * Author: Nick Smith
 * Created: 09/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_43.02_CreateUniqueAndSingleIndexesOnTableDORSTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Unique And Single Indexes On Table DORSTrainerLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_DORSTrainerLicenceSchemeTrainerTypeName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [UX_DORSTrainerLicenceSchemeTrainerTypeName] ON [dbo].[DORSTrainerLicence];
		END
		
		--Now Create Unique Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_DORSTrainerLicenceSchemeTrainerTypeName] ON [dbo].[DORSTrainerLicence]
		(
			[DORSSchemeIdentifier], [DORSTrainerIdentifier], [DORSTrainerLicenceTypeName]
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceSchemeIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceSchemeIdentifier] ON [dbo].[DORSTrainerLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceSchemeIdentifier] ON [dbo].[DORSTrainerLicence]
		(
			[DORSSchemeIdentifier]
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceTrainerIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceTrainerIdentifier] ON [dbo].[DORSTrainerLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceTrainerIdentifier] ON [dbo].[DORSTrainerLicence]
		(
			[DORSTrainerIdentifier]
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceTrainerLicenceTypeName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence]
		(
			[DORSTrainerLicenceTypeName]
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceTrainerLicenceStateName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceTrainerLicenceStateName] ON [dbo].[DORSTrainerLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceTrainerLicenceStateName] ON [dbo].[DORSTrainerLicence]
		(
			[DORSTrainerLicenceStateName]
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

