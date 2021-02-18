
/*
 * SCRIPT: Add Missing Indexes to table ClientPreviousId.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_60.01_AddMissingIndexesClientPreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPreviousId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPreviousIdClientId' 
				AND object_id = OBJECT_ID('ClientPreviousId'))
		BEGIN
		   DROP INDEX [IX_ClientPreviousIdClientId] ON [dbo].[ClientPreviousId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPreviousIdClientId] ON [dbo].[ClientPreviousId]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPreviousIdPreviousClientId' 
				AND object_id = OBJECT_ID('ClientPreviousId'))
		BEGIN
		   DROP INDEX [IX_ClientPreviousIdPreviousClientId] ON [dbo].[ClientPreviousId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPreviousIdPreviousClientId] ON [dbo].[ClientPreviousId]
		(
			[PreviousClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

