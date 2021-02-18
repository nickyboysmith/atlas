/*
	SCRIPT: Create OrganisationEmailTemplateMessage Table
	Author: Nick Smith
	Created: 02/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_15.01_Create_OrganisationEmailTemplateMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationEmailTemplateMessage Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationEmailTemplateMessage'
		
		/*
		 *	Create OrganisationEmailTemplateMessage Table
		 */
		IF OBJECT_ID('dbo.OrganisationEmailTemplateMessage', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationEmailTemplateMessage;
		END

		CREATE TABLE OrganisationEmailTemplateMessage(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, Code VARCHAR(20)
			, Name VARCHAR(100)
			, [Subject] VARCHAR(100)
			, Content VARCHAR(1000)
			, DateLastUpdated DATETIME
			, UpdatedByUserId INT
			, CONSTRAINT FK_OrganisationEmailTemplateMessage_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationEmailTemplateMessage_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;