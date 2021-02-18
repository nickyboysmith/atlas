/*
 * SCRIPT: Create EmailServiceCredential Table
 * Author: Miles Stewart
 * Created: 08/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP015_22.01_CreateEmailServiceCredentialTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create EmailServiceCredential Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailServiceCredential'
		
			/*
		 *	Create DORSConnectionNotification Table
		 */
		IF OBJECT_ID('dbo.EmailServiceCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailServiceCredential;
		END

		CREATE TABLE EmailServiceCredential(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailServiceId int NOT NULL
			, [Key] varchar(50)
			, Value varchar(320)
			, CONSTRAINT FK_EmailServiceCredential_EmailService FOREIGN KEY (EmailServiceId) REFERENCES [EmailService](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

