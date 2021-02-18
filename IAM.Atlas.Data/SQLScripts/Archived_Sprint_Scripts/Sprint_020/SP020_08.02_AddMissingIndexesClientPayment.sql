
/*
 * SCRIPT: Add Missing Indexes to table ClientPayment.
 * Author: Robert Newnham
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_08.02_AddMissingIndexesClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentPaymentId' 
				AND object_id = OBJECT_ID('ClientPayment'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentPaymentId] ON [dbo].[ClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentPaymentId] ON [dbo].[ClientPayment]
		(
			[PaymentId] ASC
		);
		
		/*******************************************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentClientId' 
				AND object_id = OBJECT_ID('ClientPayment'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentClientId] ON [dbo].[ClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentClientId] ON [dbo].[ClientPayment]
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

