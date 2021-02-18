
/*
 * SCRIPT: Drop And ReCreate Unique And Single Indexs On Table DORSTrainerLicence
 * Author: Nick Smith
 * Created: 14/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_04.01_DropAndReCreateUniqueAndSingleIndexesOnTableDORSTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop And ReCreate Unique And Single Indexes On Table DORSTrainerLicence';
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

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_DORSTrainerLicenceDORSSchemeIdentifierDORSTrainerIdentifierDORSTrainerLicenceTypeName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [UX_DORSTrainerLicenceDORSSchemeIdentifierDORSTrainerIdentifierDORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence];
		END

		
		--Now Create Unique Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_DORSTrainerLicenceDORSSchemeIdentifierDORSTrainerIdentifierDORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence]
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceDORSSchemeIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceDORSSchemeIdentifier] ON [dbo].[DORSTrainerLicence];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceDORSSchemeIdentifier] ON [dbo].[DORSTrainerLicence]
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceDORSTrainerIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceDORSTrainerIdentifier] ON [dbo].[DORSTrainerLicence];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceDORSTrainerIdentifier] ON [dbo].[DORSTrainerLicence]
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceDORSTrainerLicenceTypeName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceDORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceDORSTrainerLicenceTypeName] ON [dbo].[DORSTrainerLicence]
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceDORSTrainerLicenceStateName' 
				AND object_id = OBJECT_ID('DORSTrainerLicence'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceDORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicence];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceDORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicence]
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

