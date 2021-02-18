/*
	SCRIPT:  Create RefundPayment Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.05_Create_RefundPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundPayment Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundPayment'
		
		/*
		 *	Create RefundNote Table
		 */
		IF OBJECT_ID('dbo.RefundPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundPayment;
		END

		CREATE TABLE RefundPayment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId INT NOT NULL
			, RefundId INT NOT NULL INDEX IX_RefundPaymentRefundId NONCLUSTERED
			, RefundPaymentId INT NULL INDEX IX_RefundPaymentRefundPaymentId NONCLUSTERED
			, CONSTRAINT FK_RefundPayment_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_RefundPayment_Payment2 FOREIGN KEY (RefundPaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_RefundPayment_Refund FOREIGN KEY (RefundId) REFERENCES Refund(Id)
			, CONSTRAINT UX_RefundPaymentPaymentIdRefundId UNIQUE (PaymentId, RefundId) 
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;