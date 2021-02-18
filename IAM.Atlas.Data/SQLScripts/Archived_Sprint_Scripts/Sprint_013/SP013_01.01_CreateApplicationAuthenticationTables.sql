


/*
	SCRIPT: Create Application Authentication Tables
	Author: NickSmith
	Created: 10/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_01.01_CreateApplicationAuthenticationTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Application Authentication Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'SystemState'

		/*
			Create Table SystemState
		*/
		IF OBJECT_ID('dbo.SystemState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemState;
		END

		CREATE TABLE SystemState(
			Id int PRIMARY KEY NOT NULL
			, Colour Varchar(20) 
			, ColourHexCode Varchar(20) 
			, ImageName Varchar(100) 
		);

		IF OBJECT_ID('dbo.SystemState', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName) VALUES (0, 'Unknown', 'CCFFFF', 'bullet_Level0.png')
			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName) VALUES (1, 'Green', 'ADEBAD', 'bullet_Level1.png')
			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName) VALUES (2, 'Grey', 'D9D9D9', 'bullet_Level2.png')
			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName) VALUES (3, 'Amber', 'FFBF00', 'bullet_Level3.png')
			INSERT INTO dbo.SystemState(Id, Colour, ColourHexCode, ImageName) VALUES (4, 'Red', 'FF9999', 'bullet_Level4.png')

		END


		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'LoginState'

		/*
			Create Table ReferringAuthorityNote
		*/
		IF OBJECT_ID('dbo.LoginState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LoginState;
		END

		CREATE TABLE LoginState(
			Id int PRIMARY KEY NOT NULL
			, Name Varchar(100) NOT NULL
			, [Description] Varchar(400) 
		);
		
		
		IF OBJECT_ID('dbo.LoginState', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (0, 'Unknown', 'Unknown')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (1, 'Logged In', 'Logged into the System')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (2, 'Timed Out', 'The User''s session has timed out')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (3, 'Disabled', 'The User''s login has been disabled')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (4, 'New Password Required', 'The User needs to enter a new Password')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (5, 'Password Pin Required', 'The User needs to enter a new Password with a Password Pin number')
			INSERT INTO dbo.LoginState(Id, Name, [Description]) VALUES (9, 'No State', 'The User is Logged out')
		END
		
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'LoginSession'

		/*
			Create Table LoginSession
		*/
		IF OBJECT_ID('dbo.LoginSession', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LoginSession;
		END

		CREATE TABLE LoginSession(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, LoginId int NOT NULL 
			, DateTimeLoggedIn DateTime NOT NULL DEFAULT GetDate()
			, DateTimeLastAction DateTime NOT NULL DEFAULT GetDate()
			, SessionActive bit DEFAULT 1
			, Token Varchar(100) NOT NULL
			, SessionLogoutRequested bit DEFAULT 0
			, CONSTRAINT FK_LoginSession_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

