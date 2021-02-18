/*
	SCRIPT: Create PaymentCard Table
	Author: Dan Hough
	Created: 24/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_06.01_Create_PaymentCard';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentCard Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCard'
		
		/*
		 *	Create PaymentCard Table
		 */
		IF OBJECT_ID('dbo.PaymentCard', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCard;
		END

		CREATE TABLE PaymentCard(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId int
			, PaymentCardSupplierId int NULL
			, PaymentProviderId int NULL
			, PaymentProviderTransactionReference varchar(200) NULL
			, TransactionDate DateTime
			, DateCreated DateTime
			, CreatedByUserId int
			, CONSTRAINT FK_PaymentCard_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_PaymentCard_PaymentCardSupplier FOREIGN KEY (PaymentCardSupplierId) REFERENCES PaymentCardSupplier(Id)
			, CONSTRAINT FK_PaymentCard_PaymentProvider FOREIGN KEY (PaymentProviderId) REFERENCES PaymentProvider(Id)
			, CONSTRAINT FK_PaymentCard_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;