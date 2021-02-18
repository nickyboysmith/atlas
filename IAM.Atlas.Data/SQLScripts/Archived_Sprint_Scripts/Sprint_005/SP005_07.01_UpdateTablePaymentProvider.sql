

/*
	SCRIPT: Update Table PaymentProvider
	Author: Robert Newnham
	Created: 10/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_07.01_UpdateTablePaymentProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table PaymentProvider
		*/
		ALTER TABLE dbo.PaymentProvider
		ADD OrganisationId int NOT NULL
		, CONSTRAINT FK_PaymentProvider_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

