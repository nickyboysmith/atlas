
/*
 * SCRIPT: Add Missing Indexes to table ClientDocument.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_49.01_AddMissingIndexesClientDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientDocument';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDocumentClientId' 
				AND object_id = OBJECT_ID('ClientDocument'))
		BEGIN
		   DROP INDEX [IX_ClientDocumentClientId] ON [dbo].[ClientDocument];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDocumentClientId] ON [dbo].[ClientDocument]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDocumentDocumentId' 
				AND object_id = OBJECT_ID('ClientDocument'))
		BEGIN
		   DROP INDEX [IX_ClientDocumentDocumentId] ON [dbo].[ClientDocument];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDocumentDocumentId] ON [dbo].[ClientDocument]
		(
			[DocumentId] ASC
		);
		
		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDocumentClientIdDocumentId' 
				AND object_id = OBJECT_ID('ClientDocument'))
		BEGIN
		   DROP INDEX [IX_ClientDocumentClientIdDocumentId] ON [dbo].[ClientDocument];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDocumentClientIdDocumentId] ON [dbo].[ClientDocument]
		(
			[ClientId], [DocumentId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

