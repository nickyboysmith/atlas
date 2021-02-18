/*
	SCRIPT: Create OrganisationSystemTaskMessaging Table
	Author: Dan Murray	
	Created: 22/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_31.01_Create_OrganisationSystemTaskMessaging.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationSystemTaskMessaging Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationSystemTaskMessaging'
		
		/*
		 *	Create OrganisationSystemTaskMessaging Table
		 */
		IF OBJECT_ID('dbo.OrganisationSystemTaskMessaging', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationSystemTaskMessaging;
		END

		CREATE TABLE OrganisationSystemTaskMessaging(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , OrganisationId INT
		  , SystemTaskId INT
		  , SendMessagesViaEmail BIT DEFAULT (1) 
		  , SendMessagesViaInternalMessaging BIT DEFAULT (1)
		  , UpdatedByUserId INT 
		  , DateUpdated DATETIME
		  , CONSTRAINT FK_OrganisationSystemTaskMessaging_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		  , CONSTRAINT FK_OrganisationSystemTaskMessaging_SystemTask FOREIGN KEY (SystemTaskId) REFERENCES [SystemTask](Id)
		  , CONSTRAINT FK_OrganisationSystemTaskMessaging_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		  
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;