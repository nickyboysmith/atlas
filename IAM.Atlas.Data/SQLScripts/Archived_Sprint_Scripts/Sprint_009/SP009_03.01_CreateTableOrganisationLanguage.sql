

/*
	SCRIPT: Create OrganisationLanguage Table
	Author: Dan Murray
	Created: 23/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_03.01_CreateTableOrganisationLanguage.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationLanguage'

		/*
			Create Table OrganisationLanguage
		*/
		IF OBJECT_ID('dbo.[OrganisationLanguage]', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.[OrganisationLanguage];
		END

		CREATE TABLE [OrganisationLanguage](
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL 
			, LanguageId int NOT NULL 
			, [Disabled] bit
			, [Default] bit	
			, CONSTRAINT FK_OrganisationLanguage_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_OrganisationLanguage_Language FOREIGN KEY (LanguageId) REFERENCES [Language](Id)					
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

