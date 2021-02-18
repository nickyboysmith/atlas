/*
 * SCRIPT: Add Missing Indexes to table Payment.
 * Author: Robert Newnham
 * Created: 01/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_10.01_AddMissingIndexesPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table Payment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentPaymentMethodId' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentPaymentMethodId] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentPaymentMethodId] ON [dbo].[Payment]
		(
			[PaymentMethodId] ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentPaymentTypeId' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentPaymentTypeId] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentPaymentTypeId] ON [dbo].[Payment]
		(
			[PaymentTypeId] ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentCreatedByUserIdDateCreated' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentCreatedByUserIdDateCreated] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentCreatedByUserIdDateCreated] ON [dbo].[Payment]
		(
			[CreatedByUserId], [DateCreated] ASC
		);
		
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
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentTransactionDate' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentTransactionDate] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentTransactionDate] ON [dbo].[Payment]
		(
			[TransactionDate] ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentPaymentName' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentPaymentName] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentPaymentName] ON [dbo].[Payment]
		(
			[PaymentName] ASC
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

