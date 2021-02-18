/*
	SCRIPT: Create PaymentCardLog Table
	Author: Dan Hough
	Created: 24/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_07.01_Create_PaymentCardLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentCardLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardLog'
		
		/*
		 *	Create PaymentCardLog Table
		 */
		IF OBJECT_ID('dbo.PaymentCardLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardLog;
		END

		CREATE TABLE PaymentCardLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , PaymentCardId int
			, ChangeType varchar(20) NULL 
			, LogType varchar(20) NOT NULL
			, DateChanged DateTime NOT NULL
			, PaymentId int
			, PaymentCardSupplierId int NULL
			, PaymentProviderId int NULL
			, PaymentProviderTransactionReference varchar(200) NULL
			, TransactionDate DateTime
			, DateCreated DateTime
			, CreatedByUserId int
			, LogDate DateTime

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;