/*
	SCRIPT: Add DisplayName Column To PaymentCardType Table
	Author: Miles Stewart
	Created: 29/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_16.01_AddDisplayNameToPaymentCardType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add DisplayName Column To PaymentCardType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.PaymentCardType
			ADD DisplayName VARCHAR(40);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;