/*
	SCRIPT:  Update PaymentType Table
	Author:  Miles Stewart
	Created: 06/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_06.01_UpdatePaymentTypeTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a new column called disabled, and set it to false';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update PaymentType Table
		*/
		ALTER TABLE dbo.PaymentType 
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