/*
	SCRIPT: Create SMSServiceSendingFailure Table
	Author: Nick Smith
	Created: 31/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_09.01_ReCreate_SMSServiceSendingFailure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ReCreate SMSServiceSendingFailure Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SMSServiceSendingFailure'
		
		/*
		 *	Create SMSServiceSendingFailure Table
		 */
		IF OBJECT_ID('dbo.SMSServiceSendingFailure', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSServiceSendingFailure;
		END

		CREATE TABLE SMSServiceSendingFailure(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SMSServiceId INT 
			, DateFailed DATETIME NOT NULL
			, FailureInfo VARCHAR(400) NOT NULL
			, CONSTRAINT FK_SMSServiceSendingFailure_SMSService FOREIGN KEY (SMSServiceId) REFERENCES SMSService(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;