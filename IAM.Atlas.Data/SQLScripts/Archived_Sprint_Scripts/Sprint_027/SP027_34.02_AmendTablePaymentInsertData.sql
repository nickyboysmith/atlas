/*
 * SCRIPT: Alter Table Payment, Data for new column NetcallPayment
 * Author: Robert Newnham
 * Created: 15/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_34.02_AmendTablePaymentInsertData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Payment, Add new column NetcallPayment Update the Data';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.Payment
		SET NetcallPayment = 'False'
		WHERE NetcallPayment IS NULL
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
