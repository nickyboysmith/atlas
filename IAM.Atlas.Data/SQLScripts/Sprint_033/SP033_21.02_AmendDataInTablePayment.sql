/*
 * SCRIPT: Alter Data in Table Payment
 * Author: Robert Newnham
 * Created: 15/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_21.02_AmendDataInTablePayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Data in Table Payment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE P
		SET P.PaymentMethodId = PCTPM.PaymentMethodId
		FROM [dbo].[Payment] P
		INNER JOIN [dbo].[PaymentCard] PC ON PC.PaymentId = P.Id
		INNER JOIN [dbo].[PaymentCardTypePaymentMethod] PCTPM ON PCTPM.PaymentCardTypeId = PC.PaymentCardTypeId
		WHERE P.PaymentMethodId IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
