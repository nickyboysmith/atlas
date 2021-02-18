/*
	SCRIPT: Remove Columns On Payment Provider Table
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_01.03_RemoveColumnsOnPaymentProviderTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Columns On Payment Provider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Remove columns on PaymentProvider Table
		 */
		IF OBJECT_ID('dbo.PaymentProvider', 'U') IS NOT NULL
		BEGIN

			ALTER TABLE dbo.PaymentProvider DROP COLUMN  ProviderCode; 
			ALTER TABLE dbo.PaymentProvider DROP COLUMN  ShortCode; 
			ALTER TABLE dbo.PaymentProvider DROP COLUMN  OrganisationId; 

		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;