/*
	SCRIPT: Empty Payment Provider Table
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_01.01_EmptyPaymentProviderTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Empty Payment Provider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/



		/*
		 *	Drop Constraints if they Exist
		 */		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_PaymentCard_PaymentProvider')
				   AND parent_object_id = OBJECT_ID(N'dbo.PaymentCard')
		)
		BEGIN
			ALTER TABLE PaymentCard DROP CONSTRAINT FK_PaymentCard_PaymentProvider;
		END

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentProvider'
		

		/*
		 *	Empty PaymentProvider Table
		 */
		TRUNCATE TABLE dbo.PaymentProvider;
		


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;