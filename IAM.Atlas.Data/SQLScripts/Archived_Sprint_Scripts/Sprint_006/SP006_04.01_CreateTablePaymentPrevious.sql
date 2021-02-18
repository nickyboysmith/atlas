


/*
	SCRIPT: Create PaymentPrevious Table
	Author: Robert Newnham
	Created: 30/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP006_04.01_CreateTablePaymentPrevious.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'PaymentPreviousId'

		/*
			Create Table PaymentPreviousId
		*/
		IF OBJECT_ID('dbo.PaymentPreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentPreviousId;
		END

		CREATE TABLE PaymentPreviousId(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId int NOT NULL
			, PreviousPaymentId int NOT NULL
			, CONSTRAINT FK_PaymentPreviousId_Payment FOREIGN KEY (PaymentId) REFERENCES [Payment](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

