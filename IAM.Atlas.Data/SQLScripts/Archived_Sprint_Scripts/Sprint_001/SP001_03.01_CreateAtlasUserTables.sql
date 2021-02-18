
/*
	SCRIPT: Create User Tables
	Author: Robert Newnham
	Created: 07/04/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP001_03.01_CreateAtlasUserTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationUser'
			EXEC dbo.uspDropTableContraints 'User'

		/*
			Create Table Organisation
		*/
		IF OBJECT_ID('dbo.Organisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Organisation;
		END

		CREATE TABLE Organisation(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(100)
			, CreationTime DateTime
		);


		/*
			Create Table User
		*/
		IF OBJECT_ID('dbo.User', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.[User];
		END

		CREATE TABLE [User](
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LoginId varchar(20) NOT NULL
			, Password varchar(100)
			, Name varchar(100) NOT NULL
			, Email varchar(200)
			, Phone varchar(20)
			, PasswordChangePin int 
			, CreationTime DateTime
			, FailedLogins int 
		);


		/*
			Create Table tblOrganisationUser
		*/
		IF OBJECT_ID('dbo.OrganisationUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationUser;
		END

		CREATE TABLE OrganisationUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int
			, UserId int
			, CreationTime DateTime
			, CONSTRAINT FK_OrganisationUser_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT UC_OrganisationUser UNIQUE (OrganisationId, UserId)
		);

		/*
			Create Table UserLogins
		*/
		IF OBJECT_ID('dbo.UserLogins', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserLogins;
		END

		CREATE TABLE UserLogins(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LoginId varchar(20) 
			, Browser varchar(50) 
			, Os varchar(50)
			, Ip varchar(200)
			, Success bit 
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




