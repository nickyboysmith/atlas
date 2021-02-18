/*
	SCRIPT:  Create Refund Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.06_Create_CancelledRefund.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CancelledRefund Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CancelledRefund'
		
		/*
		 *	Create CancelledRefund Table
		 */
		IF OBJECT_ID('dbo.CancelledRefund', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CancelledRefund;
		END

		CREATE TABLE CancelledRefund(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RefundId INT NOT NULL 
			, DateCancelled DATETIME NOT NULL DEFAULT GETDATE()
			, CancelledByUserId INT NOT NULL
			, CONSTRAINT FK_CancelledRefund_Refund FOREIGN KEY (RefundId) REFERENCES Refund(Id)
			, CONSTRAINT FK_CancelledRefund_User FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;