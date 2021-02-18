/*
	SCRIPT: Create Payment Validation Tables
	Author: Robert Newnham
	Created: 08/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_11.01_CreatePaymentValidationTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Payment Validation Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardValidationType'
		
		/*
		 *	Create PaymentCardValidationType Table
		 */
		IF OBJECT_ID('dbo.PaymentCardValidationType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardValidationType;
		END
		
		CREATE TABLE PaymentCardValidationType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardValidationTypeVariation'
		
		/*
		 *	Create PaymentCardValidationTypeVariation Table
		 */
		IF OBJECT_ID('dbo.PaymentCardValidationTypeVariation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardValidationTypeVariation;
		END

		CREATE TABLE PaymentCardValidationTypeVariation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentCardValidationTypeId INT NOT NULL
			, IssuerIdentificationCharacters VARCHAR(8) NOT NULL
			, CreatedByUserId INT NOT NULL
			, DateTimeCreated DATETIME NOT NULL DEFAULT GETDATE()
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, DateTimeDisabled DATETIME NULL
			, DisabledByUserId INT  NULL
			, CONSTRAINT FK_PaymentCardValidationTypeVariation_PaymentCardValidationType FOREIGN KEY (PaymentCardValidationTypeId) REFERENCES PaymentCardValidationType(Id)
			, CONSTRAINT FK_PaymentCardValidationTypeVariation_CreatedByUser FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_PaymentCardValidationTypeVariation_DisabledByUser FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardValidationTypeLength'
		
		/*
		 *	Create PaymentCardValidationTypeLength Table
		 */
		IF OBJECT_ID('dbo.PaymentCardValidationTypeLength', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardValidationTypeLength;
		END

		CREATE TABLE PaymentCardValidationTypeLength(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentCardValidationTypeId INT NOT NULL
			, ValidLength INT NOT NULL
			, CreatedByUserId INT NOT NULL
			, DateTimeCreated DATETIME NOT NULL DEFAULT GETDATE()
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, DateTimeDisabled DATETIME NULL
			, DisabledByUserId INT  NULL
			, CONSTRAINT FK_PaymentCardValidationTypeLength_PaymentCardValidationType FOREIGN KEY (PaymentCardValidationTypeId) REFERENCES PaymentCardValidationType(Id)
			, CONSTRAINT FK_PaymentCardValidationTypeLength_CreatedByUser FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_PaymentCardValidationTypeLength_DisabledByUser FOREIGN KEY (DisabledByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END