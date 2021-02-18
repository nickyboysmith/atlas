/*
	SCRIPT: Amend Table PaymentCardType
	Author: Robert Newnham
	Created: 08/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_11.02_AmendTablePaymentCardType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table PaymentCardType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.PaymentCardType
		ADD [Disabled] BIT NOT NULL DEFAULT 'False'
		, PaymentCardValidationTypeId INT NULL
		, CONSTRAINT FK_PaymentCardType_PaymentCardValidationType FOREIGN KEY (PaymentCardValidationTypeId) REFERENCES PaymentCardValidationType(Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END