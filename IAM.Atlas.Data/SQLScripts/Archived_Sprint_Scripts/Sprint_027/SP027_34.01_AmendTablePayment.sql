/*
 * SCRIPT: Alter Table Payment, Add new column NetcallPayment
 * Author: Robert Newnham
 * Created: 15/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_34.01_AmendTablePayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Payment, Add new column NetcallPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Payment
		ADD NetcallPayment BIT DEFAULT 'False'
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
