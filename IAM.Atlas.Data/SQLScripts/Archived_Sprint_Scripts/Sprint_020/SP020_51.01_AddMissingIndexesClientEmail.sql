
/*
 * SCRIPT: Add Missing Indexes to table ClientEmail.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_51.01_AddMissingIndexesClientEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientEmail';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientEmailClientId' 
				AND object_id = OBJECT_ID('ClientEmail'))
		BEGIN
		   DROP INDEX [IX_ClientEmailClientId] ON [dbo].[ClientEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientEmailClientId] ON [dbo].[ClientEmail]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientEmailEmailId' 
				AND object_id = OBJECT_ID('ClientEmail'))
		BEGIN
		   DROP INDEX [IX_ClientEmailEmailId] ON [dbo].[ClientEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientEmailEmailId] ON [dbo].[ClientEmail]
		(
			[EmailId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

