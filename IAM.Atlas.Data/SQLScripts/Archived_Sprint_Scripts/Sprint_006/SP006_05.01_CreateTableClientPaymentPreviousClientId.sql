

/*
	SCRIPT: Create ClientPaymentPreviousClientId Table
	Author: Robert Newnham
	Created: 03/08/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP006_05.01_CreateTableClientPaymentPreviousClientId.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientPaymentPreviousClientId'

		/*
			Create Table ClientPaymentPreviousClientId
		*/
		IF OBJECT_ID('dbo.ClientPaymentPreviousClientId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientPaymentPreviousClientId;
		END

		CREATE TABLE ClientPaymentPreviousClientId(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId int NOT NULL
			, ClientId int NULL
			, PreviousClientId int NOT NULL
			, CONSTRAINT FK_ClientPaymentPreviousClientId_Payment FOREIGN KEY (PaymentId) REFERENCES [Payment](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

