


/*
	SCRIPT: Create Payment Tables
	Author: Robert Newnham
	Created: 18/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_05.01_CreatePaymentTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'PaymentMethod'
			EXEC dbo.uspDropTableContraints 'PaymentType'
			EXEC dbo.uspDropTableContraints 'OrganisationPaymentType'
			EXEC dbo.uspDropTableContraints 'PaymentProvider'
			EXEC dbo.uspDropTableContraints 'OrganisationPaymentProvider'
			EXEC dbo.uspDropTableContraints 'Payment'
			EXEC dbo.uspDropTableContraints 'ClientPayment'
			EXEC dbo.uspDropTableContraints 'ClientPaymentNote'
			EXEC dbo.uspDropTableContraints 'ClientPaymentLink'

		/*
			Create Table PaymentMethod
		*/
		IF OBJECT_ID('dbo.PaymentMethod', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentMethod;
		END

		CREATE TABLE PaymentMethod(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, [Description] Varchar(400) NULL
			, Code Varchar(20) NULL
		);

		/*
			Create Table PaymentType
		*/
		IF OBJECT_ID('dbo.PaymentType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentType;
		END

		CREATE TABLE PaymentType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(100) NOT NULL
		);

		/*
			Create Table OrganisationPaymentType
		*/
		IF OBJECT_ID('dbo.OrganisationPaymentType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPaymentType;
		END

		CREATE TABLE OrganisationPaymentType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, PaymentTypeId int NOT NULL
			, CONSTRAINT FK_OrganisationPaymentType_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationPaymentType_PaymentType FOREIGN KEY (PaymentTypeId) REFERENCES PaymentType(Id)
		);

		/*
			Create Table PaymentProvider
		*/
		IF OBJECT_ID('dbo.PaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentProvider;
		END

		CREATE TABLE PaymentProvider(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, ProviderCode Varchar(100) NOT NULL
			, ShortCode Varchar(40) NOT NULL
		);

		/*
			Create Table OrganisationPaymentProvider
		*/
		IF OBJECT_ID('dbo.OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPaymentProvider;
		END

		CREATE TABLE OrganisationPaymentProvider(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, PaymentProviderId int NOT NULL
			, CONSTRAINT FK_OrganisationPaymentProvider_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationPaymentProvider_PaymentProvider FOREIGN KEY (PaymentProviderId) REFERENCES PaymentProvider(Id)
		);

		/*
			Create Table Payment
		*/
		IF OBJECT_ID('dbo.Payment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Payment;
		END

		CREATE TABLE Payment(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateCreated DateTime NULL
			, TransactionDate DateTime NOT NULL
			, Amount Money NOT NULL
			, PaymentTypeId int NULL
			, PaymentMethodId int NULL
			, ReceiptNumber Varchar(100) NULL
			, AuthCode Varchar(100) NULL
			, CreatedByUserId int NOT NULL
			, CONSTRAINT FK_Payment_PaymentType FOREIGN KEY (PaymentTypeId) REFERENCES PaymentType(Id)
			, CONSTRAINT FK_Payment_PaymentMethod FOREIGN KEY (PaymentMethodId) REFERENCES PaymentMethod(Id)
			, CONSTRAINT FK_Payment_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);

		/*
			Create Table ClientPayment
		*/
		IF OBJECT_ID('dbo.ClientPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientPayment;
		END

		CREATE TABLE ClientPayment(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int NOT NULL
			, PaymentId int NOT NULL
			, CONSTRAINT FK_ClientPayment_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientPayment_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
		);

		/*
			Create Table ClientPaymentNote
		*/
		IF OBJECT_ID('dbo.ClientPaymentNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientPaymentNote;
		END

		CREATE TABLE ClientPaymentNote(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int NOT NULL
			, PaymentId int NOT NULL
			, NoteId int NOT NULL
			, CONSTRAINT FK_ClientPaymentNote_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientPaymentNote_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_ClientPaymentNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
		);

		/*
			Create Table ClientPaymentLink
		*/
		IF OBJECT_ID('dbo.ClientPaymentLink', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientPaymentLink;
		END

		CREATE TABLE ClientPaymentLink(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int NOT NULL
			, PaymentId int NOT NULL
			, LinkDateTime DateTime NOT NULL
			, LinkCode Varchar(100) NOT NULL
			, CONSTRAINT FK_ClientPaymentLink_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientPaymentLink_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

