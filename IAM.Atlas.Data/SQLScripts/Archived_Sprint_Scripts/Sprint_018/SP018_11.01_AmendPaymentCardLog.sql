/*
 * SCRIPT: Alter Table PaymentCardLog - add in PaymentCardTypeId
 * Author: Dan Hough
 * Created: 31/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_11.01_AmendPaymentCardLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to PaymentCardLog table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.PaymentCardLog
		  ADD PaymentCardTypeId int 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;