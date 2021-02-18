/*
	SCRIPT: Create Search History Tables
	Author: Paul Tuck
	Created: 15/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_01.01_CreateTablesSearchHistory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creates tables used to store a user''s search history';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'SearchHistoryInterface'
			EXEC dbo.uspDropTableContraints 'SearchHistoryUser'
			EXEC dbo.uspDropTableContraints 'SearchHistoryItem'
		
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.SearchHistoryItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SearchHistoryItem;
		END
		
		IF OBJECT_ID('dbo.SearchHistoryUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SearchHistoryUser;
		END
		
		IF OBJECT_ID('dbo.SearchHistoryInterface', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SearchHistoryInterface;
		END
		
		/*
			Create Table SearchHistoryInterface
		*/
		CREATE TABLE SearchHistoryInterface(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(50) NOT NULL
			, Title varchar(200)
		);
		
		/*
			Create Table SearchHistoryUser
		*/
		CREATE TABLE SearchHistoryUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SearchHistoryInterfaceId INT NOT NULL
			, UserId int NOT NULL
			, CreationDate Datetime NOT NULL
			, CONSTRAINT FK_SearchHistoryUserUserId_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_SearchHistoryInterfaceId_SearchHistoryInterface FOREIGN KEY (SearchHistoryInterfaceId) REFERENCES [SearchHistoryInterface](Id)
		);
		
		/*
			Create Table SearchHistoryItem
		*/
		CREATE TABLE SearchHistoryItem(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SearchHistoryUserId INT NOT NULL
			, Name varchar(50) NOT NULL
			, Value varchar(200) NOT NULL
			, CONSTRAINT FK_SearchHistoryUserId_SearchHistoryUser FOREIGN KEY (SearchHistoryUserId) REFERENCES [SearchHistoryUser](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


