/*
	SCRIPT: Create CancelledRefundRequest Table 
	Author: Paul Tuck
	Created: 13/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_17.01_Create_Table_CancelledRefundRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundType Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CancelledRefundRequest'
		
		/*
		 *	Create CancelledRefundRequest Table
		 */
		IF OBJECT_ID('dbo.CancelledRefundRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CancelledRefundRequest;
		END

		CREATE TABLE CancelledRefundRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RefundRequestId INT NOT NULL
			, DateCancelled DATETIME NOT NULL DEFAULT GETDATE()
			, CancelledByUserId INT NOT NULL
			, CONSTRAINT FK_CancelledRefundRequest_RefundRequest FOREIGN KEY (RefundRequestId) REFERENCES RefundRequest(Id)
			, CONSTRAINT FK_CancelledRefundRequest_User FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;