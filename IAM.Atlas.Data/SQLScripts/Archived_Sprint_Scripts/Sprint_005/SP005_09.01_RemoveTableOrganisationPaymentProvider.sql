


/*
	SCRIPT: Remove OrganisationPaymentProvider Table
	Author: Robert Newnham
	Created: 05/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP005_09.01_RemoveTableOrganisationPaymentProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationPaymentProvider'

		/*
			Create Table OrganisationPaymentProvider
		*/
		IF OBJECT_ID('dbo.OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPaymentProvider;
		END

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

