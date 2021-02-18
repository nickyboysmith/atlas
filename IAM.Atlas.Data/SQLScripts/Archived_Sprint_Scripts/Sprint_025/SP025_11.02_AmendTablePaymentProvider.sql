/*
 * SCRIPT: Alter Table PaymentProvider 
 * Author: Robert Newnham
 * Created: 26/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP025_11.02_AmendTablePaymentProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Column to PaymentProvider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.PaymentProvider
			ADD SystemDefault BIT DEFAULT 'False'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
