


/*
	SCRIPT: Create Report and User Related Tables
	Author: Robert Newnham
	Created: 18/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_02.01_CreateTablesReportAndUser.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationReport'
			EXEC dbo.uspDropTableContraints 'OrganisationReportCategory'
			EXEC dbo.uspDropTableContraints 'UserReport'
			EXEC dbo.uspDropTableContraints 'ReportOwner'
			EXEC dbo.uspDropTableContraints 'OrganisationAdminUser'
			EXEC dbo.uspDropTableContraints 'SystemAdminUser'

		/*
			Create Table OrganisationReport
		*/
		IF OBJECT_ID('dbo.OrganisationReport', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationReport;
		END

		CREATE TABLE OrganisationReport(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, ReportId int NOT NULL
			, CONSTRAINT FK_OrganisationReport_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationReport_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
		);

		/*
			Create Table OrganisationReportCategory
		*/
		IF OBJECT_ID('dbo.OrganisationReportCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationReportCategory;
		END

		CREATE TABLE OrganisationReportCategory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, ReportCategoryId int NOT NULL
			, CONSTRAINT FK_OrganisationReportCategory_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationReportCategory_ReportCategory FOREIGN KEY (ReportCategoryId) REFERENCES ReportCategory(Id)
		);
		
		/*
			Create Table UserReport
		*/
		IF OBJECT_ID('dbo.UserReport', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserReport;
		END

		CREATE TABLE UserReport(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, ReportId int NOT NULL
			, CONSTRAINT FK_UserReport_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_UserReport_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
		);

		/*
			Create Table ReportOwner
		*/
		IF OBJECT_ID('dbo.ReportOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportOwner;
		END

		CREATE TABLE ReportOwner(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId int NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_ReportOwner_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
			, CONSTRAINT FK_ReportOwner_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		/*
			Create Table OrganisationAdminUser
		*/
		IF OBJECT_ID('dbo.OrganisationAdminUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationAdminUser;
		END

		CREATE TABLE OrganisationAdminUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_OrganisationAdminUser_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationAdminUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		/*
			Create Table SystemAdminUser
		*/
		IF OBJECT_ID('dbo.SystemAdminUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemAdminUser;
		END

		CREATE TABLE SystemAdminUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_SystemAdminUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		/*
			Update Table Report
		*/
		IF NOT EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'CreatedByUserId' and Object_ID = Object_ID(N'Report')
					)
		BEGIN
			ALTER TABLE dbo.Report
			ADD 
				CreatedByUserId int NULL
				, DateCreated DateTime NULL
				, UpdatedByUserId int NULL
				, DateUpdated DateTime NULL
			;
		END


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

