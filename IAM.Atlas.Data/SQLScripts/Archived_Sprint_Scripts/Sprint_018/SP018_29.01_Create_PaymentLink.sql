/*
	SCRIPT: Create PaymentLink Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_29.01_Create_PaymentLink.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentLink Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentLink'
		
		/*
		 *	Create PaymentLink Table
		 */
		IF OBJECT_ID('dbo.PaymentLink', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentLink;
		END

		CREATE TABLE PaymentLink(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId int NOT NULL 
			, LinkedPaymentId int NOT NULL
			, DateLinked DateTime NOT NULL
			, CONSTRAINT FK_PaymentLink_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_PaymentLink_Payment1 FOREIGN KEY (LinkedPaymentId) REFERENCES Payment(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;