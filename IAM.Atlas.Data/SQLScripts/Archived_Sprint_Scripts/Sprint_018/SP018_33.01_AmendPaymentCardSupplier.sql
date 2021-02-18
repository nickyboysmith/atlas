/*
 * SCRIPT: Alter Table PaymentCardSupplier
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_33.01_AmendPaymentCardSupplier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to PaymentCardSupplier table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.PaymentCardSupplier
		 ADD PaymentCardProviderId int NULL
		, CONSTRAINT FK_PaymentCardSupplier_PaymentCardProvider FOREIGN KEY (PaymentCardProviderId) REFERENCES PaymentCardProvider(Id)

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;