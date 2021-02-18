/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @ScriptName VARCHAR(100) = 'SP002_01.01_CreateAtlasClientTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Created Client, Address, PhoneType, Email, Note, ClientOrganisation, ClientAddress, ClientPhone, ClientEmail and ClientNote tables.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
                BEGIN
                                EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
                                /***START OF SCRIPT***/

                                /*
                                                Drop Constraints if they Exist
                                */
                                                EXEC dbo.uspDropTableContraints 'ClientOrganisation'
                                                EXEC dbo.uspDropTableContraints 'ClientAddress'
                                                EXEC dbo.uspDropTableContraints 'ClientPhone'
                                                EXEC dbo.uspDropTableContraints 'ClientEmail'
                                                EXEC dbo.uspDropTableContraints 'ClientNote'
                                                EXEC dbo.uspDropTableContraints 'Address'
                                                EXEC dbo.uspDropTableContraints 'Client'
                                /*
                                                Create Table Client
                                */
                                IF OBJECT_ID('dbo.Client', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.Client;
                                                
                                END

                                CREATE TABLE Client(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , Title varchar(50) 
                                                , FirstName varchar(50)
                                                , Surname varchar(50) 
                                                , OtherNames varchar(50)
                                                , DisplayName varchar(200)
                                                , DateOfBirth DateTime 
                                                , Locked Bit
                                );


                                /*
                                                Create Table Address
                                */
                                IF OBJECT_ID('dbo.Address', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.[Address];
                                END

                                CREATE TABLE [Address](
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , [Address] varchar(500) 
                                                , PostCode varchar(20)
                                );


								/*
                                                Create Table PhoneType
                                */
                                IF OBJECT_ID('dbo.PhoneType', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.PhoneType;
                                END

                                CREATE TABLE PhoneType(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , [Type] varchar(10)
                                                , CONSTRAINT CHK_PhoneType CHECK ([Type] IN ('Daily', 'Weekly', 'Monthly', 'Yearly'))

                                               
                                );

								/*
                                                Create Table Email
                                */
                                IF OBJECT_ID('dbo.Email', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.Email;
                                END

                                CREATE TABLE Email(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , Email varchar(100)
                                                                                               
                                );

                                /*
                                                Create Table Note
                                */
                                IF OBJECT_ID('dbo.Note', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.Note;
                                                
                                END

                                CREATE TABLE Note(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , Note varchar(1000) 
                                                , DateCreated DateTime
                                                , CreatedByUserId int NOT NULL 
                                                , Removed bit
                                );
                               
                               
                                /*
                                                Create Table ClientOrganisation
                                */
                                IF OBJECT_ID('dbo.ClientOrganisation', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.ClientOrganisation;
                                END

                                CREATE TABLE ClientOrganisation(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , ClientId int NOT NULL
                                                , OrganisationId int NOT NULL
                                                , CONSTRAINT FK_ClientOrganisation_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
                                                , CONSTRAINT FK_ClientOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
                                                , CONSTRAINT UC_ClientOrganisation UNIQUE (ClientId, OrganisationId)
                                );
                               
                                /*
                                                Create Table ClientAddress
                                */
                                IF OBJECT_ID('dbo.ClientAddress', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.ClientAddress;
                                END

                                CREATE TABLE ClientAddress(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , ClientId int NOT NULL
                                                , AddressId int NOT NULL
                                                , CONSTRAINT FK_ClientAddress_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
                                                , CONSTRAINT FK_ClientAddress_Address FOREIGN KEY (AddressId) REFERENCES [Address](Id)
                                                , CONSTRAINT UC_ClientAddress UNIQUE (ClientId, AddressId)
                                );
                               
                                /*
                                                Create Table ClientPhone
                                */
                                IF OBJECT_ID('dbo.ClientPhone', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.ClientPhone;
                                END

                                CREATE TABLE ClientPhone(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , ClientId int NOT NULL
                                                , PhoneTypeId int NOT NULL
                                                , CONSTRAINT FK_ClientPhone_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
                                                , CONSTRAINT FK_ClientPhone_Phone FOREIGN KEY (PhoneTypeId) REFERENCES [PhoneType](Id)
                                                , CONSTRAINT UC_ClientPhone UNIQUE (ClientId, PhoneTypeId)
                                );
                               
                               
                                /*
                                                Create Table ClientEmail
                                */
                                IF OBJECT_ID('dbo.ClientEmail', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.ClientEmail;
                                END

                                CREATE TABLE ClientEmail(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , ClientId int NOT NULL
                                                , EmailId int NOT NULL
                                                , CONSTRAINT FK_ClientEmail_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
                                                , CONSTRAINT FK_ClientEmail_Email FOREIGN KEY (EmailId) REFERENCES [Email](Id)
                                                , CONSTRAINT UC_ClientEmail UNIQUE (ClientId, EmailId)
                                );
                               
                               
                                /*
                                                Create Table ClientNote
                                */
                                IF OBJECT_ID('dbo.ClientNote', 'U') IS NOT NULL
                                BEGIN
                                                DROP TABLE dbo.ClientNote;
                                END

                                CREATE TABLE ClientNote(
                                                Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
                                                , ClientId int NOT NULL
                                                , NoteId int NOT NULL
                                                , CONSTRAINT FK_ClientNote_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
                                                , CONSTRAINT FK_ClientNote_Email FOREIGN KEY (NoteId) REFERENCES [Note](Id)
                                                , CONSTRAINT UC_ClientNote UNIQUE (ClientId, NoteId)
                                );
                               
                                /***END OF SCRIPT***/
                                EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
                END
ELSE
                BEGIN
                                PRINT '******Script "' + @ScriptName + '" Not Run******';
                END
;
