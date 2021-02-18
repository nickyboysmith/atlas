/*
	SCRIPT:  Create CourseGroupEmailRequest Table 
	Author: Dan Hough
	Created: 06/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_07.01_Create_CourseGroupEmailRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseGroupEmailRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseGroupEmailRequest'
		
		/*
		 *	Create CourseGroupEmailRequest Table
		 */
		IF OBJECT_ID('dbo.CourseGroupEmailRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseGroupEmailRequest;
		END

		CREATE TABLE CourseGroupEmailRequest(
				Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
				, DateRequested DATETIME NOT NULL
				, RequestedByUserId INT NOT NULL
				, SendAllClients BIT NOT NULL DEFAULT 'False'
				, SendAllTrainers BIT NOT NULL DEFAULT 'False'
				, SeparateEmails BIT NOT NULL DEFAULT 'False'
				, OneEmailWithHiddenAddresses BIT NOT NULL DEFAULT 'False'
				, CCEmailAddress VARCHAR(1000) NULL
				, BCCEmailAddress VARCHAR(1000) NULL
				, [Subject] VARCHAR(1000) NOT NULL
				, StartDearNamed BIT NOT NULL DEFAULT 'False'
				, StartDearSirMadam BIT NOT NULL DEFAULT 'False'
				, StartToWhomItMayConcern BIT NOT NULL DEFAULT 'False'
				, Content VARCHAR(4000) NOT NULL
				, SendASAP BIT NOT NULL DEFAULT 'False'
				, SendAfterDateTime DATETIME NULL
				, EmailsValidatedAndCreated BIT NOT NULL DEFAULT 'False'
				, DateEmailsValidatedAndCreated DATETIME NULL
				, RequestRejected BIT NOT NULL DEFAULT 'False'
				, RejectionReason VARCHAR(200) NULL
				, CONSTRAINT FK_CourseGroupEmailRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
				);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;