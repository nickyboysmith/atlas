


/*
	SCRIPT: Update Table PaymentProvider
	Author: Robert Newnham
	Created: 10/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_08.01_UpdateTablePaymentProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table PaymentProvider
		*/
		ALTER TABLE dbo.PaymentProvider
		ALTER COLUMN ProviderCode Varchar(100) NULL;
		
		ALTER TABLE dbo.PaymentProvider
		ALTER COLUMN ShortCode Varchar(40) NULL;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

