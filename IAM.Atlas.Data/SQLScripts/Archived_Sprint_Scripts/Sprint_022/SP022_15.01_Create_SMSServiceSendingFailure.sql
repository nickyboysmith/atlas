/*
	SCRIPT: Create SMSServiceSendingFailure Table
	Author: Dan Hough
	Created: 29/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_15.01_Create_SMSServiceSendingFailure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SMSServiceSendingFailure Table';
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
			, EmailServiceId INT 
			, DateFailed DATETIME NOT NULL
			, FailureInfo VARCHAR(400) NOT NULL
			, CONSTRAINT FK_SMSServiceSendingFailure_EmailService FOREIGN KEY (EmailServiceId) REFERENCES EmailService(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;