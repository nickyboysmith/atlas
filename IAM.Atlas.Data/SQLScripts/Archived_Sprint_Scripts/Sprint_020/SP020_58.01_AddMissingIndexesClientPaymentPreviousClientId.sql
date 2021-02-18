
/*
 * SCRIPT: Add Missing Indexes to table ClientPaymentPreviousClientId.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_58.01_AddMissingIndexesClientPaymentPreviousClientId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPaymentPreviousClientId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentPreviousClientIdClientId' 
				AND object_id = OBJECT_ID('ClientPaymentPreviousClientId'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentPreviousClientIdClientId] ON [dbo].[ClientPaymentPreviousClientId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentPreviousClientIdClientId] ON [dbo].[ClientPaymentPreviousClientId]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentPreviousClientIdPaymentId' 
				AND object_id = OBJECT_ID('ClientPaymentPreviousClientId'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentPreviousClientIdPaymentId] ON [dbo].[ClientPaymentPreviousClientId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentPreviousClientIdPaymentId] ON [dbo].[ClientPaymentPreviousClientId]
		(
			[PaymentId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentPreviousClientIdPreviousClientId' 
				AND object_id = OBJECT_ID('ClientPaymentPreviousClientId'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentPreviousClientIdPreviousClientId] ON [dbo].[ClientPaymentPreviousClientId];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentPreviousClientIdPreviousClientId] ON [dbo].[ClientPaymentPreviousClientId]
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

