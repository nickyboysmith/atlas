
/*
 * SCRIPT: Add Missing Indexes to table ClientNote.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_54.01_AddMissingIndexesClientNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientNoteClientId' 
				AND object_id = OBJECT_ID('ClientNote'))
		BEGIN
		   DROP INDEX [IX_ClientNoteClientId] ON [dbo].[ClientNote];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientNoteClientId] ON [dbo].[ClientNote]
		(
			[ClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

