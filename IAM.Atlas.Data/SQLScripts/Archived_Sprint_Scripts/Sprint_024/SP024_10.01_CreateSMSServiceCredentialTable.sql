/*
 * SCRIPT: Create SMSServiceCredential Table
 * Author: Miles Stewart
 * Created: 02/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_10.01_CreateSMSServiceCredentialTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SMSServiceCredential Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SMSServiceCredential'
		
			/*
		 *	Create DORSConnectionNotification Table
		 */
		IF OBJECT_ID('dbo.SMSServiceCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSServiceCredential;
		END

		CREATE TABLE SMSServiceCredential(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SMSServiceId int NOT NULL
			, [Key] varchar(50)
			, Value varchar(320)
			, CONSTRAINT FK_SMSServiceCredential_SMSService FOREIGN KEY (SMSServiceId) REFERENCES [SMSService](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

