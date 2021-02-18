/*
 * SCRIPT: Create Table EmailsBlockedOutgoing 
 * Author: Robert Newnham
 * Created: 08/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_03.01_CreateTableEmailsBlockedOutgoing.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table EmailsBlockedOutgoing';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailsBlockedOutgoing'
		
		/*
		 *	Create EmailsBlockedOutgoing Table
		 */
		IF OBJECT_ID('dbo.EmailsBlockedOutgoing', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailsBlockedOutgoing;
		END

		CREATE TABLE EmailsBlockedOutgoing(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NULL
			, Email VARCHAR(320) NULL
			, DateCreated DATETIME NULL DEFAULT Getdate()
			, CONSTRAINT FK_EmailsBlockedOutgoing_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		INSERT INTO EmailsBlockedOutgoing (Email) VALUES ('fake_person@iam.fake_email.com');
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;