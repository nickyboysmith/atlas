/*
	SCRIPT: Fix Referring Authority Table Errors
	Author: Robert Newnham
	Created: 15/08/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_30.01_FixReferringAuthorityTableErrors.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Referring Authority Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ClientDORSData_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ClientDORSData')
					)
		BEGIN
			ALTER TABLE [dbo].[ClientDORSData] 
			DROP CONSTRAINT [FK_ClientDORSData_ReferringAuthority];
		END
	
		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_ReferringAuthorityUserDepartment_ReferringAuthority')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityUserDepartment')
					)
		BEGIN
			ALTER TABLE [dbo].[ReferringAuthorityUserDepartment] 
			DROP CONSTRAINT [FK_ReferringAuthorityUserDepartment_ReferringAuthority];
		END
	
		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityUser_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityUser')
					)
		BEGIN
			ALTER TABLE [dbo].[ReferringAuthorityUser] 
			DROP CONSTRAINT [FK_ReferringAuthorityUser_ReferringAuthority];
		END
	
		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityDepartment_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityDepartment')
					)
		BEGIN
			ALTER TABLE [dbo].[ReferringAuthorityDepartment] 
			DROP CONSTRAINT [FK_ReferringAuthorityDepartment_ReferringAuthority];
		END
	
		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityContract_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityContract')
					)
		BEGIN
			ALTER TABLE [dbo].[ReferringAuthorityContract] 
			DROP CONSTRAINT [FK_ReferringAuthorityContract_ReferringAuthority];
		END
	
		/*************************************************************************/
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityClient_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityClient')
					)
		BEGIN
			ALTER TABLE [dbo].[ReferringAuthorityClient] 
			DROP CONSTRAINT [FK_ReferringAuthorityClient_ReferringAuthority];
		END
	
		/*************************************************************************/
	
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
				
		CREATE TABLE [dbo].[ReferringAuthority](
			[Id] [int] IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] [varchar](100) NULL
			, [Description] [varchar](200) NULL
			, [Disabled] [bit] NULL DEFAULT ((0))
			, [AssociatedOrganisationId] [int] NULL
			, [CreatedByUserId] [int] NULL
			, [DateCreated] [datetime] NULL DEFAULT (getdate())
			, [UpdatedByUserId] [int] NULL
			, [DateUpdated] [datetime] NULL
			, CONSTRAINT FK_ReferringAuthority_Organisation FOREIGN KEY (AssociatedOrganisationId) REFERENCES Organisation([Id])
			, CONSTRAINT FK_ReferringAuthority_User FOREIGN KEY (CreatedByUserId) REFERENCES [User]([Id])
			, CONSTRAINT FK_ReferringAuthority_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User]([Id])
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
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReferringAuthorityId int NOT NULL 
			, NoteId int NOT NULL
			, CONSTRAINT FK_ReferringAuthorityNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			, CONSTRAINT FK_ReferringAuthorityNote_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id)
		);
		
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ClientDORSData_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ClientDORSData')
					)
		BEGIN
			DELETE FROM [dbo].[ClientDORSData];
			ALTER TABLE [dbo].[ClientDORSData] 
			ADD CONSTRAINT [FK_ClientDORSData_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_ReferringAuthorityUserDepartment_ReferringAuthority')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityUserDepartment')
					)
		BEGIN
			DELETE FROM [dbo].[ReferringAuthorityUserDepartment];
			ALTER TABLE [dbo].[ReferringAuthorityUserDepartment] 
			ADD CONSTRAINT [FK_ReferringAuthorityUserDepartment_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityUser_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityUser')
					)
		BEGIN
			DELETE FROM [dbo].[ReferringAuthorityUser];
			ALTER TABLE [dbo].[ReferringAuthorityUser] 
			ADD CONSTRAINT [FK_ReferringAuthorityUser_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityDepartment_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityDepartment')
					)
		BEGIN
			DELETE FROM [dbo].[ReferringAuthorityDepartment];
			ALTER TABLE [dbo].[ReferringAuthorityDepartment] 
			ADD CONSTRAINT [FK_ReferringAuthorityDepartmentDepartment_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityContract_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityContract')
					)
		BEGIN
			DELETE FROM [dbo].[ReferringAuthorityContract];
			ALTER TABLE [dbo].[ReferringAuthorityContract] 
			ADD CONSTRAINT [FK_ReferringAuthorityContract_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		/*************************************************************************/
		IF NOT EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.[FK_ReferringAuthorityClient_ReferringAuthority]')
					AND parent_object_id = OBJECT_ID(N'dbo.ReferringAuthorityClient')
					)
		BEGIN
			DELETE FROM [dbo].[ReferringAuthorityClient];
			ALTER TABLE [dbo].[ReferringAuthorityClient] 
			ADD CONSTRAINT [FK_ReferringAuthorityClient_ReferringAuthority] FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id);
		END
	
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

