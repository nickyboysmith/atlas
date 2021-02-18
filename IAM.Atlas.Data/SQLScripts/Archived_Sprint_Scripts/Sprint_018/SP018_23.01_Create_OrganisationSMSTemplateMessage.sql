/*
	SCRIPT: Create OrganisationSMSTemplateMessage Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_23.01_Create_OrganisationSMSTemplateMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationSMSTemplateMessage Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationSMSTemplateMessage'
		
		/*
		 *	Create OrganisationSMSTemplateMessage Table
		 */
		IF OBJECT_ID('dbo.OrganisationSMSTemplateMessage', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationSMSTemplateMessage;
		END

		CREATE TABLE OrganisationSMSTemplateMessage(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, Code varchar(4)
			, Name varchar(40)
			, Content varchar(600)
			, CONSTRAINT FK_OrganisationSMSTemplateMessage_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;