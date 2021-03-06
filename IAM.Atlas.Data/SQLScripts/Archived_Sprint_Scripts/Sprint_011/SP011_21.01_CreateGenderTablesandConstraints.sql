


/*
	SCRIPT: Create CreateGenderTableandConstraints
	Author: NickSmith
	Created: 17/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_21.01_CreateGenderTableandConstraints.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Gender Tables With Constraints';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'Gender'

		/*
			Create Table Gender
		*/
		IF OBJECT_ID('dbo.Gender', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Gender;
		END


		CREATE TABLE Gender(
			Id int PRIMARY KEY NOT NULL
			, Name Varchar(100) -- 100 ? 
		);
		
		IF OBJECT_ID('dbo.Gender', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.Gender(Id, Name) VALUES (0, 'Female')
			INSERT INTO dbo.Gender(Id, Name) VALUES (1, 'Male')
			INSERT INTO dbo.Gender(Id, Name) VALUES (8, 'Not Stated')
			INSERT INTO dbo.Gender(Id, Name) VALUES (9, 'Unknown')
		END
	
		/* Add GenderId as Foreign Key to User, Client and Trainer tables */
		
	    /* Amend User Table to include the GenderId and add foreign key constraint */
	    
	    /* TODO - check default of 9 is OK */
	    
		ALTER TABLE dbo.[User]
		ADD GenderId int NOT NULL DEFAULT (9)
		, CONSTRAINT FK_User_Gender FOREIGN KEY (GenderId) REFERENCES Gender(Id);
		
		/* Amend Client Table to include the GenderId and add foreign key constraint */
		
		ALTER TABLE dbo.[Client]
		ADD GenderId int NOT NULL DEFAULT (9)
		, CONSTRAINT FK_Client_Gender FOREIGN KEY (GenderId) REFERENCES Gender(Id);
		
		/* Amend Trainer Table to include the GenderId and add foreign key constraint */
		
		ALTER TABLE dbo.[Trainer]
		ADD GenderId int NOT NULL DEFAULT (9)
		, CONSTRAINT FK_Trainer_Gender FOREIGN KEY (GenderId) REFERENCES Gender(Id);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

