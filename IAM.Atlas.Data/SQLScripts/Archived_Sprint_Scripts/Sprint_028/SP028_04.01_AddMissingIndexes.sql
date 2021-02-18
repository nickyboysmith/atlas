
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 20/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_04.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentDateCreated' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentDateCreated] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentDateCreated] ON [dbo].[Payment]
		(
			[DateCreated] ASC
		) INCLUDE ([Amount], [CreatedByUserId], [Refund]) WITH (ONLINE = ON);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceStateIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainerLicenceState'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceStateIdentifier] ON [dbo].[DORSTrainerLicenceState];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceStateIdentifier] ON [dbo].[DORSTrainerLicenceState]
		(
			[Identifier] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceStateName' 
				AND object_id = OBJECT_ID('DORSTrainerLicenceState'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicenceState];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicenceState]
		(
			[Name] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerTrainerId' 
				AND object_id = OBJECT_ID('DORSTrainer'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerTrainerId] ON [dbo].[DORSTrainer];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerTrainerId] ON [dbo].[DORSTrainer]
		(
			[TrainerId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerDORSTrainerIdentifier' 
				AND object_id = OBJECT_ID('DORSTrainer'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerDORSTrainerIdentifier] ON [dbo].[DORSTrainer];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerDORSTrainerIdentifier] ON [dbo].[DORSTrainer]
		(
			[DORSTrainerIdentifier] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerSchemeDORSTrainerId' 
				AND object_id = OBJECT_ID('DORSTrainerScheme'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerSchemeDORSTrainerId] ON [dbo].[DORSTrainerScheme];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerSchemeDORSTrainerId] ON [dbo].[DORSTrainerScheme]
		(
			[DORSTrainerId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerSchemeDORSTrainerIdDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSTrainerScheme'))
		BEGIN
		   DROP INDEX [IX_DORSTrainerSchemeDORSTrainerIdDORSSchemeId] ON [dbo].[DORSTrainerScheme];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSTrainerSchemeDORSTrainerIdDORSSchemeId] ON [dbo].[DORSTrainerScheme]
		(
			[DORSTrainerId], [DORSSchemeId] ASC
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

