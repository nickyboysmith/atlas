/*
	SCRIPT: Create OrganisationContact Tables
	Author: Nick Smith
	Created: 17/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP016_05.01_CreateOrganisationContactTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationContact Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationContact'
		
			/*
		 *	Create OrganisationContact Table
		 */
		IF OBJECT_ID('dbo.OrganisationContact', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationContact;
		END

		CREATE TABLE OrganisationContact(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, LocationId int NULL
			, EmailId int NULL
			, PhoneNumber varchar(40) NULL 
			, CONSTRAINT FK_OrganisationContact_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_OrganisationContact_Location FOREIGN KEY (LocationId) REFERENCES [Location](Id)
			, CONSTRAINT FK_OrganisationContact_Email FOREIGN KEY (EmailId) REFERENCES [Email](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;