/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration Add column OnlineBookingTermsDocumentId
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_17.01_AmendOrganisationSelfConfigurationAddColumnOnlineBookingTermsDocumentId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column OnlineBookingTermsDocumentId to OrganisationSelfConfiguration table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
			 ADD OnlineBookingTermsDocumentId INT 
			 , CONSTRAINT FK_OrganisationSelfConfiguration_Document FOREIGN KEY (OnlineBookingTermsDocumentId) REFERENCES Document(Id)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;