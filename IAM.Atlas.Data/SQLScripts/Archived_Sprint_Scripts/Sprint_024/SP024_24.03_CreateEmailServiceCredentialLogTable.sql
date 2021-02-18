/*
 * SCRIPT: Create EmailServiceCredentialLog Table
 * Author: Robert Newnham
 * Created: 09/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_24.03_CreateEmailServiceCredentialLogTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create EmailServiceCredentialLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailServiceCredentialLog'
		
		/*
		 *	Create EmailServiceCredentialLog Table
		 */
		IF OBJECT_ID('dbo.EmailServiceCredentialLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailServiceCredentialLog;
		END

		CREATE TABLE EmailServiceCredentialLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailServiceCredentialId INT NOT NULL
			, EmailServiceId INT NOT NULL
			, [Key] VARCHAR(50)
			, Value VARCHAR(320)
			, DateUpdated DATETIME
			, UpdatedByUserId INT
			, Notes VARCHAR(200)
			, CONSTRAINT FK_EmailServiceCredentialLog_EmailService FOREIGN KEY (EmailServiceId) REFERENCES [EmailService](Id)
			, CONSTRAINT FK_EmailServiceCredentialLog_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_EmailServiceCredentialLog_EmailServiceCredential FOREIGN KEY (EmailServiceCredentialId) REFERENCES [EmailServiceCredential](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

