
/*
	SCRIPT: Create Interpreter Tables
	Author: Robert Newnham
	Created: 07/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_04.01_CreateInterpreterTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Interpreter Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseInterpreter'
		EXEC dbo.uspDropTableContraints 'InterpreterLocation'
		EXEC dbo.uspDropTableContraints 'InterpreterPhone'
		EXEC dbo.uspDropTableContraints 'InterpreterNote'
		EXEC dbo.uspDropTableContraints 'InterpreterEmail'
		EXEC dbo.uspDropTableContraints 'InterpreterLanguage'
		EXEC dbo.uspDropTableContraints 'InterpreterOrganisation'
		EXEC dbo.uspDropTableContraints 'Interpreter'
		
		/*
			Create Table Interpreter
		*/
		IF OBJECT_ID('dbo.Interpreter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Interpreter;
		END

        CREATE TABLE Interpreter(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , Title varchar(40) 
            , FirstName varchar(100) NOT NULL
            , Surname varchar(100) NOT NULL
            , OtherNames varchar(200)
            , DisplayName varchar(200)
            , DateOfBirth DateTime 
            , GenderId int NOT NULL
            , [Disabled] Bit NOT NULL DEFAULT 'False'
            , DateCreated DateTime NOT NULL DEFAULT GETDATE()
            , CreatedByUserId int NOT NULL
            , DateUpdated DateTime NULL
            , UpdatedByUserId int NULL
            , CONSTRAINT FK_Interpreter_Gender FOREIGN KEY (GenderId) REFERENCES Gender(Id)
        );
		
        /*
            Create Table InterpreterOrganisation
        */
        IF OBJECT_ID('dbo.InterpreterOrganisation', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.InterpreterOrganisation;
        END

        CREATE TABLE InterpreterOrganisation(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterOrganisationInterpreterId NONCLUSTERED
            , OrganisationId int NOT NULL INDEX IX_InterpreterOrganisationOrganisationId NONCLUSTERED
            , CONSTRAINT FK_InterpreterOrganisation_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
            , CONSTRAINT UX_InterpreterOrganisation UNIQUE (InterpreterId, OrganisationId)
        );
       
        /*
            Create Table InterpreterLanguage
        */
        IF OBJECT_ID('dbo.InterpreterLanguage', 'U') IS NOT NULL
        BEGIN
                DROP TABLE dbo.InterpreterLanguage;
        END

        CREATE TABLE InterpreterLanguage(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterLanguageInterpreterId NONCLUSTERED
            , LanguageId int NOT NULL INDEX IX_InterpreterLanguageLanguageId NONCLUSTERED
            , Main Bit NOT NULL DEFAULT 'False'
            , CONSTRAINT FK_InterpreterLanguage_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterLanguage_Language FOREIGN KEY (LanguageId) REFERENCES [Language](Id)
            , CONSTRAINT UX_InterpreterLanguage UNIQUE (InterpreterId, LanguageId)
        );
       
       
        /*
            Create Table InterpreterEmail
        */
        IF OBJECT_ID('dbo.InterpreterEmail', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.InterpreterEmail;
        END

        CREATE TABLE InterpreterEmail(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterEmailInterpreterId NONCLUSTERED
            , EmailId int NOT NULL INDEX IX_InterpreterEmailEmailId NONCLUSTERED
            , Main Bit NOT NULL DEFAULT 'False'
            , CONSTRAINT FK_InterpreterEmail_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterEmail_Email FOREIGN KEY (EmailId) REFERENCES [Email](Id)
            , CONSTRAINT UX_InterpreterEmail UNIQUE (InterpreterId, EmailId)
        );
       
        /*
            Create Table InterpreterNote
        */
        IF OBJECT_ID('dbo.InterpreterNote', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.InterpreterNote;
        END

        CREATE TABLE InterpreterNote(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterNoteInterpreterId NONCLUSTERED
            , NoteId int NOT NULL INDEX IX_InterpreterNoteNoteId NONCLUSTERED
            , CONSTRAINT FK_InterpreterNote_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterNote_Note FOREIGN KEY (NoteId) REFERENCES [Note](Id)
            , CONSTRAINT UX_InterpreterNote UNIQUE (InterpreterId, NoteId)
        );
       
        /*
            Create Table InterpreterPhone
        */
        IF OBJECT_ID('dbo.InterpreterPhone', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.InterpreterPhone;
        END

        CREATE TABLE InterpreterPhone(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterPhoneInterpreterId NONCLUSTERED
            , PhoneTypeId int NOT NULL INDEX IX_InterpreterPhonePhoneTypeId NONCLUSTERED
            , Number varchar(40) NOT NULL
            , CONSTRAINT FK_InterpreterPhone_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterPhone_Phone FOREIGN KEY (PhoneTypeId) REFERENCES [PhoneType](Id)
            , CONSTRAINT UX_InterpreterPhone UNIQUE (InterpreterId, PhoneTypeId)
        );
       
        /*
            Create Table InterpreterLocation
        */
        IF OBJECT_ID('dbo.InterpreterLocation', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.InterpreterLocation;
        END

        CREATE TABLE InterpreterLocation(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , InterpreterId int NOT NULL INDEX IX_InterpreterLocationInterpreterId NONCLUSTERED
            , LocationId int NOT NULL INDEX IX_InterpreterLocationLocationId NONCLUSTERED
            , Main Bit NOT NULL DEFAULT 'False'
            , CONSTRAINT FK_InterpreterLocation_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_InterpreterLocation_Location FOREIGN KEY (LocationId) REFERENCES [Location](Id)
            , CONSTRAINT UX_InterpreterLocation UNIQUE (InterpreterId, LocationId)
        );
       
        /*
            Create Table CourseInterpreter
        */
        IF OBJECT_ID('dbo.CourseInterpreter', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.CourseInterpreter;
        END

        CREATE TABLE CourseInterpreter(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , CourseId int NOT NULL INDEX IX_CourseInterpreterCourseId NONCLUSTERED
            , InterpreterId int NOT NULL INDEX IX_CourseInterpreterInterpreterId NONCLUSTERED
            , CourseDateId int NOT NULL INDEX IX_CourseInterpreterCourseDateId NONCLUSTERED
            , DateCreated DateTime NOT NULL DEFAULT GETDATE()
            , CreatedByUserId int NOT NULL
			, BookedForSessionNumber INT NULL
			, BookedForTheory BIT NOT NULL DEFAULT 'False'
			, BookedForPractical BIT NOT NULL DEFAULT 'False'
            , CONSTRAINT FK_CourseInterpreter_Interpreter FOREIGN KEY (InterpreterId) REFERENCES Interpreter(Id)
            , CONSTRAINT FK_CourseInterpreter_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
            , CONSTRAINT FK_CourseInterpreter_CourseDate FOREIGN KEY (CourseDateId) REFERENCES CourseDate(Id)
            , CONSTRAINT FK_CourseInterpreter_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
            , CONSTRAINT UX_CourseInterpreter UNIQUE (InterpreterId, CourseId)
        );
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
