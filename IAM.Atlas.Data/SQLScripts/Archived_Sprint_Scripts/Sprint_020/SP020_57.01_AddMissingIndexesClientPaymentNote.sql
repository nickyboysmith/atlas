
/*
 * SCRIPT: Add Missing Indexes to table ClientPaymentNote.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_57.01_AddMissingIndexesClientPaymentNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPaymentNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentNoteClientId' 
				AND object_id = OBJECT_ID('ClientPaymentNote'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentNoteClientId] ON [dbo].[ClientPaymentNote];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentNoteClientId] ON [dbo].[ClientPaymentNote]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentNotePaymentId' 
				AND object_id = OBJECT_ID('ClientPaymentNote'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentNotePaymentId] ON [dbo].[ClientPaymentNote];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentNotePaymentId] ON [dbo].[ClientPaymentNote]
		(
			[PaymentId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

