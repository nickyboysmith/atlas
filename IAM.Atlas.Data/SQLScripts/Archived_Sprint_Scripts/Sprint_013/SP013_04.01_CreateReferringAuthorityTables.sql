


/*
	SCRIPT: Create Referring Authority Tables
	Author: NickSmith
	Created: 10/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_04.01_CreateReferringAuthorityTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Referring Authority Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'ReferringAuthority'

		/*
			Create Table ReferringAuthority
		*/
		IF OBJECT_ID('dbo.ReferringAuthority', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthority;
		END

		CREATE TABLE ReferringAuthority(
			Id int PRIMARY KEY NOT NULL
			, Name Varchar(100) NOT NULL
			, [Description] Varchar(200)
		);


		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityNote'

		/*
			Create Table ReferringAuthorityNote
		*/
		IF OBJECT_ID('dbo.ReferringAuthorityNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityNote;
		END

		CREATE TABLE ReferringAuthorityNote(
			Id int PRIMARY KEY NOT NULL
			, NoteId int NOT NULL
			, CONSTRAINT FK_ReferringAuthorityNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
		);
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityContract'

		/*
			Create Table ReferringAuthorityContract
		*/
		IF OBJECT_ID('dbo.ReferringAuthorityContract', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityContract;
		END

		CREATE TABLE ReferringAuthorityContract(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, ReferringAuthorityId int NOT NULL 
			, Reference Varchar(100)
			, StartDate DateTime 
			, EndDate DateTime 
			, CONSTRAINT FK_ReferringAuthorityContract_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_ReferringAuthorityContract_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id)
		);
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityUser'

		/*
			Create Table ReferringAuthorityUser
		*/
		IF OBJECT_ID('dbo.ReferringAuthorityUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityUser;
		END

		CREATE TABLE ReferringAuthorityUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReferringAuthorityId int NOT NULL 
			, UserId int NOT NULL
			, DateAdded DateTime NOT NULL DEFAULT GetDate()
			, AddedByUserId int NOT NULL
			, CONSTRAINT FK_ReferringAuthorityUser_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id)
			, CONSTRAINT FK_ReferringAuthorityUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ReferringAuthorityUser_User1 FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

