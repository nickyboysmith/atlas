/*
	SCRIPT: Create the Administration Tables
	Author: Miles Stewart
	Created: 06/07/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP005_05.01_CreateAdministrationMenuTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create administration menu tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'AdministrationMenuGroupItem'
		EXEC dbo.uspDropTableContraints 'AdministrationMenuItemUser'
		EXEC dbo.uspDropTableContraints 'AdministrationMenuUser'

		/*
		 * Create Administration Menu User
		 */
		IF OBJECT_ID('dbo.AdministrationMenuUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuUser;
		END

		CREATE TABLE AdministrationMenuUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_AdministrationMenuUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)

		);

		/**
		 * Create the Administration Menu Item 
		 */
		IF OBJECT_ID('dbo.AdministrationMenuItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuItem;
		END

		CREATE TABLE AdministrationMenuItem(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(50) NOT NULL
			, Url varchar(100) NOT NULL
			, [Description] varchar(250) 
			, Modal bit 
			, [Disabled] bit 
		);

		/**
		 * Create the Administration Menu Item User
		 */
		IF OBJECT_ID('dbo.AdministrationMenuItemUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuItemUser;
		END

		CREATE TABLE AdministrationMenuItemUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, AdminMenuItemId int NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_AdministrationMenuItemUser_AdministrationMenuItem FOREIGN KEY (AdminMenuItemId) REFERENCES [AdministrationMenuItem](Id)
			, CONSTRAINT FK_AdministrationMenuItemUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		/**
		 * Create the Administration Menu Group 
		 */
		IF OBJECT_ID('dbo.AdministrationMenuGroup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuGroup;
		END

		CREATE TABLE AdministrationMenuGroup(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(50) NOT NULL
			, [Description] varchar(250) NOT NULL
			, ParentGroupId int
			, SortNumber int
		);

		/**
		 * Create the Administration Menu Group Item
		 */
		IF OBJECT_ID('dbo.AdministrationMenuGroupItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AdministrationMenuGroupItem;
		END

		CREATE TABLE AdministrationMenuGroupItem(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, AdminMenuGroupId int NOT NULL
			, AdminMenuItemId int NOT NULL
			, SortNumber int
			, CONSTRAINT FK_AdministrationMenuGroupItem_AdministrationMenuGroup FOREIGN KEY (AdminMenuGroupId) REFERENCES [AdministrationMenuGroup](Id)
			, CONSTRAINT FK_AdministrationMenuGroupItem_AdministrationMenuItem FOREIGN KEY (AdminMenuItemId) REFERENCES [AdministrationMenuItem](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;