/*
	SCRIPT: Create PaymentCardType Table
	Author: Dan Hough
	Created: 31/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_09.01_Create_PaymentCardType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentCardType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardType'
		
		/*
		 *	Create PaymentCardType Table
		 */
		IF OBJECT_ID('dbo.PaymentCardType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardType;
		END

		CREATE TABLE PaymentCardType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , Name varchar(200) 
			, IssuerIdentiicationCharacters varchar(8) NULL
			, IssuerCheckDigit char(1) NULL
			, NumberOfCharacters int NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;