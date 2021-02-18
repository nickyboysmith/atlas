/*
	SCRIPT: Create OrganisationPaymentProvider Table
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_02.01_CreateOrganisationPaymentProviderTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationPaymentProvider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/*
		 *	Check the PaymentProvider Table
		 */
		IF OBJECT_ID('dbo.PaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentProvider;
		END

		/**
		 * Create PaymentProvider Table
		 */
		CREATE TABLE PaymentProvider(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, [Disabled] bit 
			, Notes Varchar(1000) NOT NULL
		);


		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationPaymentProvider'
		
		/*
		 *	Check the OrganisationPaymentProvider Table
		 */
		IF OBJECT_ID('dbo.OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPaymentProvider;
		END

		/*
		 *	Create OrganisationPaymentProvider Table
		 */
		CREATE TABLE OrganisationPaymentProvider(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
			OrganisationId INT,
			PaymentProviderId INT,
			ProviderCode VARCHAR(100),
			ShortCode VARCHAR(40),
			CONSTRAINT FK_OrganisationPaymentProvider_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id),
			CONSTRAINT FK_OrganisationPaymentProvider_PaymentProvider FOREIGN KEY (PaymentProviderId) REFERENCES [PaymentProvider](Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;