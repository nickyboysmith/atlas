/*
	SCRIPT: Create ReconciliationData Table
	Author: Dan Hough
	Created: 26/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_10.03_CreateTable_ReconciliationData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReconciliationData Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReconciliationData'
		
		/*
		 *	Create ReconciliationData Table
		 */
		IF OBJECT_ID('dbo.ReconciliationData', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReconciliationData;
		END

		CREATE TABLE ReconciliationData(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReconciliationId INT NOT NULL
			, ReconciliationTransactionDate DATE
			, ReconciliationTransactionAmount MONEY
			, ReconciliationReference1 VARCHAR(400)
			, ReconciliationReference2 VARCHAR(400)
			, ReconciliationReference3 VARCHAR(400)
			, PaymentId INT NULL
			, PaymentTransactionDate DATE
			, PaymentAmount MONEY
			, PathmentAuthCode VARCHAR(100) NULL
			, ReceiptNumber VARCHAR(100) NULL
			, Duplicate BIT NOT NULL DEFAULT 'False'
			, CONSTRAINT FK_ReconciliationData_Reconciliation FOREIGN KEY (ReconciliationId) REFERENCES Reconciliation(Id)
			, CONSTRAINT FK_ReconciliationData_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END