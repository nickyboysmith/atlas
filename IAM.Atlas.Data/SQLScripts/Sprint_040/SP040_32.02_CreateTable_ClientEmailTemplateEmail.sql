/*
	SCRIPT: Create ClientEmailTemplateEmail Table
	Author: Dan Hough
	Created: 14/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_32.02_CreateTable_ClientEmailTemplateEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientEmailTemplateEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientEmailTemplateEmail'
		
		/*
		 *	Create ClientEmailTemplateEmail Table
		 */
		IF OBJECT_ID('dbo.ClientEmailTemplateEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientEmailTemplateEmail;
		END

		CREATE TABLE ClientEmailTemplateEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientEmailTemplateId INT NOT NULL
			, ScheduledEmailId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, AddedByUserId INT NOT NULL
			, CONSTRAINT FK_ClientEmailTemplateEmail_ClientEmailTemplate FOREIGN KEY (ClientEmailTemplateId) REFERENCES ClientEmailTemplate(Id)
			, CONSTRAINT FK_ClientEmailTemplateEmail_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
			, CONSTRAINT FK_ClientEmailTemplateEmail_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END