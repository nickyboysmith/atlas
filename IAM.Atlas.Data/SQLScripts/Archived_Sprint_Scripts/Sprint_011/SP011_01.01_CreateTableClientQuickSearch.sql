/*
	SCRIPT: Create Client Quick Search Table
	Author: Dan Murray
	Created: 29/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_01.01_CreateTableClientQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a table to store client quick-search data';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientQuickSearch'
		
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.ClientQuickSearch', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientQuickSearch;
		END
		
		
		/*
			Create Table ClientQuickSearch
		*/
		CREATE TABLE ClientQuickSearch(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SearchContent VARCHAR(900) NOT NULL
			, DisplayContent VARCHAR(640) NOT NULL
			, OrganisationId INT NOT NULL
			, ClientId INT NOT NULL
			, CONSTRAINT FK_ClientQuickSearch_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_ClientQuickSearch_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		CREATE NONCLUSTERED INDEX IX_ClientSearchContent ON ClientQuickSearch (SearchContent);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


