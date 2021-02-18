/*
	SCRIPT: Create OrganisationPaymentProviderCredential Table
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_03.01_CreateOrganisationPaymentProviderCredentialTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationPaymentProviderCredential Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationPaymentProviderCredential'
		
		/*
		 *	Check the OrganisationPaymentProvider Table
		 */
		IF OBJECT_ID('dbo.OrganisationPaymentProviderCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPaymentProviderCredential;
		END
		
		/*
		 *	Create OrganisationPaymentProviderCredential Table
		 */
		CREATE TABLE OrganisationPaymentProviderCredential(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
			OrganisationId INT,
			PaymentProviderId INT,
			[Key] VARCHAR(100),
			[Value] VARCHAR(320),
			CONSTRAINT FK_OrganisationPaymentProviderCredential_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id),
			CONSTRAINT FK_OrganisationPaymentProviderCredential_PaymentProvider FOREIGN KEY (PaymentProviderId) REFERENCES [PaymentProvider](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;