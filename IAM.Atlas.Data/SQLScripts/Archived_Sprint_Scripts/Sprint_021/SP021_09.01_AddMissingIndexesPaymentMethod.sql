/*
 * SCRIPT: Add Missing Indexes to table PaymentMethod.
 * Author: Robert Newnham
 * Created: 01/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_09.01_AddMissingIndexesPaymentMethod.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table PaymentMethod';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentMethodOrganisationId' 
				AND object_id = OBJECT_ID('PaymentMethod'))
		BEGIN
		   DROP INDEX [IX_PaymentMethodOrganisationId] ON [dbo].[PaymentMethod];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentMethodOrganisationId] ON [dbo].[PaymentMethod]
		(
			[OrganisationId] ASC
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

