

/*
	SCRIPT: Add a 'disabled' boolean column to the PaymentProvider table
	Author: Dan Murray
	Created: 08/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP008_01.01_ExtendTablePaymentProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table PaymentProvider
		*/
		ALTER TABLE dbo.PaymentProvider	
		ADD [Disabled] bit
		DEFAULT 'false';
		
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

