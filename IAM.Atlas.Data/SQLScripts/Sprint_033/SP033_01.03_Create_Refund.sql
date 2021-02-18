/*
	SCRIPT:  Create Refund Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.03_Create_Refund.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundType Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'Refund'
		
		/*
		 *	Create Refund Table
		 */
		IF OBJECT_ID('dbo.Refund', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Refund;
		END

		CREATE TABLE Refund(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE() INDEX IX_RefundDateCreated NONCLUSTERED
			, TransactionDate DATETIME NOT NULL DEFAULT GETDATE() INDEX IX_RefundTransactionDate NONCLUSTERED
			, Amount MONEY
			, RefundMethodId INT NOT NULL INDEX IX_RefundRefundMethodId NONCLUSTERED
			, RefundTypeId INT NOT NULL INDEX IX_RefundRefundTypeId NONCLUSTERED
			, CreatedByUserId INT NOT NULL
			, Reference VARCHAR(100) NULL
			, PaymentName VARCHAR(320) NOT NULL INDEX IX_RefundPaymentName NONCLUSTERED
			, OrganisationId INT NOT NULL INDEX IX_RefundOrganisationId NONCLUSTERED
			, CONSTRAINT FK_Refund_RefundMethod FOREIGN KEY (RefundMethodId) REFERENCES RefundMethod(Id)
			, CONSTRAINT FK_Refund_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Refund_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;