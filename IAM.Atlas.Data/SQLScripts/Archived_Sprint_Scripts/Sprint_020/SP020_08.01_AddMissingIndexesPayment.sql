
/*
 * SCRIPT: Add Missing Indexes to table Payment.
 * Author: Robert Newnham
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_08.01_AddMissingIndexesPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table Payment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
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

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

