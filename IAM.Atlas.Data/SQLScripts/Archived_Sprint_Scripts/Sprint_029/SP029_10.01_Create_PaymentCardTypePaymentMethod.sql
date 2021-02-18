/*
	SCRIPT: Create PaymentCardTypePaymentMethod Table
	Author: Dan Hough
	Created: 16/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_10.01_Create_PaymentCardTypePaymentMethod.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PaymentCardTypePaymentMethod Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardTypePaymentMethod'
		
		/*
		 *	Create PaymentCardTypePaymentMethod Table
		 */
		IF OBJECT_ID('dbo.PaymentCardTypePaymentMethod', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardTypePaymentMethod;
		END

		CREATE TABLE PaymentCardTypePaymentMethod(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentCardTypeId INT NOT NULL
			, PaymentMethodId INT NOT NULL
			, CONSTRAINT FK_PaymentCardTypePaymentMethod_PaymentCardType FOREIGN KEY (PaymentCardTypeId) REFERENCES PaymentCardType(Id)
			, CONSTRAINT FK_PaymentCardTypePaymentMethod_PaymentMethod FOREIGN KEY (PaymentMethodId) REFERENCES PaymentMethod(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;