


/*
	SCRIPT: Create Trainer Database Tables & And Fix Table Field Sizes in Table Client
	Author: Robert Newnham
	Created: 24/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP006_02.01_CreateTrainerTablesAndFixTableClientFieldSizes.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Client
		*/
		ALTER TABLE dbo.Client
		ALTER COLUMN Title Varchar(40);
		
		ALTER TABLE dbo.Client
		ALTER COLUMN FirstName Varchar(100);

		ALTER TABLE dbo.Client
		ALTER COLUMN Surname Varchar(100);
		
		ALTER TABLE dbo.Client
		ALTER COLUMN OtherNames Varchar(100);
		
		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'TrainerCourseType'
			EXEC dbo.uspDropTableContraints 'CourseTrainer'
			EXEC dbo.uspDropTableContraints 'DriverLicenceType'
			EXEC dbo.uspDropTableContraints 'TrainerLicence'
			EXEC dbo.uspDropTableContraints 'TrainerOrganisation'
			EXEC dbo.uspDropTableContraints 'TrainerNote'
			EXEC dbo.uspDropTableContraints 'TrainerEmail'
			EXEC dbo.uspDropTableContraints 'TrainerPhone'
			EXEC dbo.uspDropTableContraints 'TrainerLocation'
			EXEC dbo.uspDropTableContraints 'Trainer'

		/*
			Create Table Trainer
		*/
		IF OBJECT_ID('dbo.Trainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Trainer;
		END

        CREATE TABLE Trainer(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , Title varchar(40) 
            , FirstName varchar(100)
            , Surname varchar(100) NOT NULL
            , OtherNames varchar(200)
            , DisplayName varchar(200)
            , DateOfBirth DateTime 
            , Locked Bit
            , PictureName varchar(100) 
            , OrganistionTitle varchar(100) 
            , OrganistionLocation varchar(100) 
        );

        /*
            Create Table TrainerLocation
        */
        IF OBJECT_ID('dbo.TrainerLocation', 'U') IS NOT NULL
        BEGIN
                DROP TABLE dbo.TrainerLocation;
        END

        CREATE TABLE TrainerLocation(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , LocationId int NOT NULL
            , MainLocation Bit
            , CONSTRAINT FK_TrainerLocation_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerLocation_Location FOREIGN KEY (LocationId) REFERENCES [Location](Id)
            , CONSTRAINT UC_TrainerLocation UNIQUE (TrainerId, LocationId)
        );
       
        /*
            Create Table TrainerPhone
        */
        IF OBJECT_ID('dbo.TrainerPhone', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TrainerPhone;
        END

        CREATE TABLE TrainerPhone(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , PhoneTypeId int NOT NULL
            , Number varchar(40) 
            , CONSTRAINT FK_TrainerPhone_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerPhone_Phone FOREIGN KEY (PhoneTypeId) REFERENCES [PhoneType](Id)
            , CONSTRAINT UC_TrainerPhone UNIQUE (TrainerId, PhoneTypeId)
        );
       
       
        /*
            Create Table TrainerEmail
        */
        IF OBJECT_ID('dbo.TrainerEmail', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TrainerEmail;
        END

        CREATE TABLE TrainerEmail(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , EmailId int NOT NULL
            , MainEmail Bit
            , CONSTRAINT FK_TrainerEmail_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerEmail_Email FOREIGN KEY (EmailId) REFERENCES [Email](Id)
            , CONSTRAINT UC_TrainerEmail UNIQUE (TrainerId, EmailId)
        );
       
       
        /*
            Create Table TrainerNote
        */
        IF OBJECT_ID('dbo.TrainerNote', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TrainerNote;
        END

        CREATE TABLE TrainerNote(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , NoteId int NOT NULL
            , CONSTRAINT FK_TrainerNote_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerNote_Email FOREIGN KEY (NoteId) REFERENCES [Note](Id)
            , CONSTRAINT UC_TrainerNote UNIQUE (TrainerId, NoteId)
        );
       
        /*
            Create Table TrainerOrganisation
        */
        IF OBJECT_ID('dbo.TrainerOrganisation', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TrainerOrganisation;
        END

        CREATE TABLE TrainerOrganisation(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , OrganisationId int NOT NULL
            , CONSTRAINT FK_TrainerOrganisation_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
            , CONSTRAINT UC_TrainerOrganisation UNIQUE (TrainerId, OrganisationId)
        );
       
		/*
			Create Table DriverLicenceType
		*/
		IF OBJECT_ID('dbo.DriverLicenceType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DriverLicenceType;
		END

		CREATE TABLE DriverLicenceType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100)
            , Disabled Bit
		);

		/*
			Rename Column in Table ClientLicence
		*/
		
		--Rename Column
		IF EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'LicenceTypeId' and Object_ID = Object_ID(N'ClientLicence')
					)
		BEGIN
			EXEC sp_RENAME 'ClientLicence.LicenceTypeId', 'DriverLicenceTypeId', 'COLUMN';
		END
		
		IF OBJECT_ID('FK_ClientLicence_DriverLicenceType', 'C') IS NULL 
		BEGIN 
			SET IDENTITY_INSERT dbo.DriverLicenceType ON; 
			
			INSERT INTO dbo.DriverLicenceType (Id, Name)
			SELECT DISTINCT DriverLicenceTypeId, 'Type ' + CAST(DriverLicenceTypeId AS VARCHAR)
			FROM dbo.ClientLicence CL
			WHERE NOT EXISTS (SELECT * FROM DriverLicenceType DLT WHERE DLT.Id = CL.DriverLicenceTypeId);
			
			ALTER TABLE dbo.ClientLicence
			ADD CONSTRAINT FK_ClientLicence_DriverLicenceType FOREIGN KEY (DriverLicenceTypeId) REFERENCES DriverLicenceType(Id);
			
			SET IDENTITY_INSERT dbo.DriverLicenceType OFF; 
		END
		
		/*
			Create Table TrainerLicence
		*/
		IF OBJECT_ID('dbo.TrainerLicence', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerLicence;
		END

		CREATE TABLE TrainerLicence(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL,
			TrainerId int NOT NULL,
			LicenceNumber varchar(40),
			LicenceExpiryDate DateTime,
			DriverLicenceTypeId int NULL,
			CONSTRAINT FK_TrainerLicence_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id),
			CONSTRAINT FK_TrainerLicence_DriverLicenceType FOREIGN KEY (DriverLicenceTypeId) REFERENCES DriverLicenceType(Id)
		);

        /*
            Create Table CourseTrainer
        */
        IF OBJECT_ID('dbo.CourseTrainer', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.CourseTrainer;
        END

        CREATE TABLE CourseTrainer(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , CourseId int NOT NULL
            , TrainerId int NOT NULL
            , DateCreated DateTime 
            , CreatedByUserId int NOT NULL
            , CONSTRAINT FK_CourseTrainer_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_CourseTrainer_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
            , CONSTRAINT FK_CourseTrainer_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
            , CONSTRAINT UC_CourseTrainer UNIQUE (TrainerId, CourseId)
        );
       
        /*
            Create Table TrainerCourseType
        */
        IF OBJECT_ID('dbo.TrainerCourseType', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.TrainerCourseType;
        END

        CREATE TABLE TrainerCourseType(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , TrainerId int NOT NULL
            , CourseTypeId int NOT NULL
            , CONSTRAINT FK_TrainerCourseType_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
            , CONSTRAINT FK_TrainerCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
            , CONSTRAINT UC_TrainerCourseType UNIQUE (TrainerId, CourseTypeId)
        );
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

