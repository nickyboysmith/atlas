/*
 * SCRIPT: Alter Table EmailServiceCredential
 * Author: Robert Newnham
 * Created: 09/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_24.02_AmendTableEmailServiceCredential.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table Email Service Credential';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		IF NOT EXISTS(SELECT * FROM sys.columns 
				WHERE Name = N'DateUpdated' AND Object_ID = Object_ID(N'EmailServiceCredential'))
		BEGIN
			ALTER TABLE dbo.EmailServiceCredential
				ADD DateUpdated DATETIME DEFAULT GetDate()
				, UpdatedByUserId INT
			, CONSTRAINT FK_EmailServiceCredential_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id);
		END
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;