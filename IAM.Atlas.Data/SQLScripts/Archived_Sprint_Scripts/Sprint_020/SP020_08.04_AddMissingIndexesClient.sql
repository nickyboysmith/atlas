
/*
 * SCRIPT: Add Missing Indexes to table ClientOrganisation.
 * Author: Robert Newnham
 * Created: 06/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_08.04_AddMissingIndexesClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table Client';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDateCreated' 
				AND object_id = OBJECT_ID('Client'))
		BEGIN
		   DROP INDEX [IX_ClientDateCreated] ON [dbo].[Client];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDateCreated] ON [dbo].[Client]
		(
			[DateCreated] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientUserId' 
				AND object_id = OBJECT_ID('Client'))
		BEGIN
		   DROP INDEX [IX_ClientUserId] ON [dbo].[Client];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientUserId] ON [dbo].[Client]
		(
			[UserId] ASC
		);
		
		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientDisplayName' 
				AND object_id = OBJECT_ID('Client'))
		BEGIN
		   DROP INDEX [IX_ClientDisplayName] ON [dbo].[Client];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientDisplayName] ON [dbo].[Client]
		(
			[DisplayName] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

