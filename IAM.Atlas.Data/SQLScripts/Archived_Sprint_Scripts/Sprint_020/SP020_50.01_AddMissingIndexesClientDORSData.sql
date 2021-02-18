
/*
 * SCRIPT: Add Missing Indexes to table ClientDORSData.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_50.01_AddMissingIndexesClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientDORSData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataClientId' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataClientId] ON [dbo].[ClientDORSData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDORSDataClientId] ON [dbo].[ClientDORSData]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataReferringAuthorityId' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataReferringAuthorityId] ON [dbo].[ClientDORSData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDORSDataReferringAuthorityId] ON [dbo].[ClientDORSData]
		(
			[ReferringAuthorityId] ASC
		);
		
		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataDORSReference' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataDORSReference] ON [dbo].[ClientDORSData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDORSDataDORSReference] ON [dbo].[ClientDORSData]
		(
			[DORSReference] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDORSDataReferringAuthorityIdClientId' 
				AND object_id = OBJECT_ID('ClientDORSData'))
		BEGIN
		   DROP INDEX [IX_ClientDORSDataReferringAuthorityIdClientId] ON [dbo].[ClientDORSData];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDORSDataReferringAuthorityIdClientId] ON [dbo].[ClientDORSData]
		(
			[ReferringAuthorityId], [ClientId] ASC
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

