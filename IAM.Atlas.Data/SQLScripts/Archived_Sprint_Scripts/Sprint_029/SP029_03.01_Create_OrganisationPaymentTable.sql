/*
	SCRIPT: Create OrganisationPayment Table
	Author: Robert Newnham
	Created: 14/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_03.01_Create_OrganisationPaymentTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationPayment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationPayment'
		
		/*
		 *	Create OrganisationPayment Table
		 */
		IF OBJECT_ID('dbo.OrganisationPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPayment;
		END

		CREATE TABLE OrganisationPayment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, PaymentId INT NOT NULL
			, CONSTRAINT FK_OrganisationPayment_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationPayment_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, INDEX UX_OrganisationPaymentOrganisationIdPaymentId UNIQUE NONCLUSTERED (OrganisationId, PaymentId)
			, INDEX IX_OrganisationPaymentOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX UX_OrganisationPaymentPaymentId UNIQUE NONCLUSTERED (PaymentId)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;