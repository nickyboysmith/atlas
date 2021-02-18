/*
 * SCRIPT: Alter Table OrganisationSMSTemplateMessage 
 * Author: Robert Newnham
 * Created: 13/09/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP026_18.01_AmendTableOrganisationSMSTemplateMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to OrganisationSMSTemplateMessage Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSMSTemplateMessage
			ADD DateLastUpdated DATETIME
			, UpdatedByUserId INT
			, CONSTRAINT FK_OrganisationSMSTemplateMessage_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
