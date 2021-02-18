
/*
 * SCRIPT: Add Missing Indexes to table ClientPaymentLink.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_56.01_AddMissingIndexesClientPaymentLink.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPaymentLink';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentLinkClientId' 
				AND object_id = OBJECT_ID('ClientPaymentLink'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentLinkClientId] ON [dbo].[ClientPaymentLink];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentLinkClientId] ON [dbo].[ClientPaymentLink]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPaymentLinkPaymentId' 
				AND object_id = OBJECT_ID('ClientPaymentLink'))
		BEGIN
		   DROP INDEX [IX_ClientPaymentLinkPaymentId] ON [dbo].[ClientPaymentLink];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPaymentLinkPaymentId] ON [dbo].[ClientPaymentLink]
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

