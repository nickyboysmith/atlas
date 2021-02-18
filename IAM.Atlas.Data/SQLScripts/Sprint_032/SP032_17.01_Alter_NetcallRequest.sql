/*
 * SCRIPT: Alter Table NetcallRequest 
 * Author: Paul Tuck
 * Created: 22/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_17.01_Alter_NetcallRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Column: ''InPaymentResult'' to NetcallRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.NetcallRequest ADD
			InPaymentResult VARCHAR(100) NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
