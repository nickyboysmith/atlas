/*
	SCRIPT: Create SendSystemAdminsEmail Table
	Author: Robert Newnham
	Created: 21/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_02.01_CreateTable_SendSystemAdminsEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SendSystemAdminsEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SendSystemAdminsEmail'
		
		/*
		 *	Create SendSystemAdminsEmail Table
		 */
		IF OBJECT_ID('dbo.SendSystemAdminsEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SendSystemAdminsEmail;
		END

		CREATE TABLE SendSystemAdminsEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateTimeRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestedByUserId INT NOT NULL
			, SubjectText VARCHAR(100)
			, ContentText VARCHAR(4000)
			, EmailSent BIT NOT NULL DEFAULT 'False'
			, DateTimeEmailSent DATETIME NULL
			, SentTo VARCHAR(1000)
			, CONSTRAINT FK_SendSystemAdminsEmail_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END