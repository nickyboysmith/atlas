


/*
	SCRIPT: Create Scheduler & Email Management Data Structure
	Author: Robert Newnham
	Created: 27/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP006_03.01_CreateSchedulerAndEmailManagementDataStructure.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ScheduledReportEmailTo'
			EXEC dbo.uspDropTableContraints 'ScheduledReportHistory'
			EXEC dbo.uspDropTableContraints 'ScheduledReportParameter'
			EXEC dbo.uspDropTableContraints 'ScheduledReport'
			EXEC dbo.uspDropTableContraints 'OrganisationPrefferedEmailService'
			EXEC dbo.uspDropTableContraints 'EmailServiceEmailCount'
			EXEC dbo.uspDropTableContraints 'EmailServiceEmailsSent'
			EXEC dbo.uspDropTableContraints 'EmailServiceNote'
			EXEC dbo.uspDropTableContraints 'EmailService'
			EXEC dbo.uspDropTableContraints 'ArchivedEmailNote'
			EXEC dbo.uspDropTableContraints 'ArchivedEmailAttachment'
			EXEC dbo.uspDropTableContraints 'ArchivedEmailTo'
			EXEC dbo.uspDropTableContraints 'ArchivedEmail'
			EXEC dbo.uspDropTableContraints 'ScheduledEmailNote'
			EXEC dbo.uspDropTableContraints 'ScheduledEmailAttachment'
			EXEC dbo.uspDropTableContraints 'ScheduledEmailTo'
			EXEC dbo.uspDropTableContraints 'ScheduledEmail'
			EXEC dbo.uspDropTableContraints 'ScheduledEmailStatus'
			EXEC dbo.uspDropTableContraints 'SchedulerControl'

		/*
			Create Table SchedulerControl
		*/
		IF OBJECT_ID('dbo.SchedulerControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SchedulerControl;
		END

        CREATE TABLE SchedulerControl(
            Id int PRIMARY KEY NOT NULL
            , EmailScheduleDisabled Bit 
            , ReportScheduleDisabled Bit 
            , ArchiveScheduleDisabled Bit 
            , SMSScheduleDisabled Bit 
        );
        
        INSERT INTO dbo.SchedulerControl (Id, EmailScheduleDisabled, ReportScheduleDisabled, ArchiveScheduleDisabled, SMSScheduleDisabled)
        SELECT 1 AS Id
				, 'False' AS EmailScheduleDisabled
				, 'False' AS ReportScheduleDisabled
				, 'False' AS ArchiveScheduleDisabled
				, 'False' AS SMSScheduleDisabled
		WHERE NOT EXISTS (SELECT * FROM dbo.SchedulerControl WHERE Id = 1);

        /*
            Create Table ScheduledEmailStatus
        */
        IF OBJECT_ID('dbo.ScheduledEmailStatus', 'U') IS NOT NULL
        BEGIN
                DROP TABLE dbo.ScheduledEmailStatus;
        END

        CREATE TABLE ScheduledEmailStatus(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , Name Varchar(100) 
        );
       
        /*
            Create Table ScheduledEmail
        */
        IF OBJECT_ID('dbo.ScheduledEmail', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledEmail;
        END

        CREATE TABLE ScheduledEmail(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , FromName Varchar(100) 
            , FromEmail Varchar(320) 
            , Content Varchar(4000) 
            , DateCreated DateTime
            , ScheduledEmailStatusId int NOT NULL
            , [Disabled] Bit
            , ASAP Bit
            , SendAfter DateTime
            , OrganisationId int NOT NULL
            , CONSTRAINT FK_ScheduledEmail_ScheduledEmailStatus FOREIGN KEY (ScheduledEmailStatusId) REFERENCES ScheduledEmailStatus(Id)
            , CONSTRAINT FK_ScheduledEmail_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
        );
       
        /*
            Create Table ScheduledEmailTo
        */
        IF OBJECT_ID('dbo.ScheduledEmailTo', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledEmailTo;
        END

        CREATE TABLE ScheduledEmailTo(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , Name Varchar(100) 
            , Email Varchar(320) 
            , CC Bit
            , BCC Bit
            , CONSTRAINT FK_ScheduledEmailTo_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
        );
       
        /*
            Create Table ScheduledEmailAttachment
        */
        IF OBJECT_ID('dbo.ScheduledEmailAttachment', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledEmailAttachment;
        END

        CREATE TABLE ScheduledEmailAttachment(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , FilePath Varchar(200)
            , CONSTRAINT FK_ScheduledEmailAttachment_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
        );
       
        /*
            Create Table ScheduledEmailNote
        */
        IF OBJECT_ID('dbo.ScheduledEmailNote', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledEmailNote;
        END

        CREATE TABLE ScheduledEmailNote(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , Note Varchar(1000)
            , CONSTRAINT FK_ScheduledEmailNote_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ScheduledEmail(Id)
        );
       
        /*
            Create Table ArchivedEmail
        */
        IF OBJECT_ID('dbo.ArchivedEmail', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ArchivedEmail;
        END

        CREATE TABLE ArchivedEmail(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , FromName Varchar(100) 
            , FromEmail Varchar(320) 
            , Content Varchar(4000) 
            , DateCreated DateTime
            , ScheduledEmailStatusId int NOT NULL
            , [Disabled] Bit
            , ASAP Bit
            , SendAfter DateTime
            , OrganisationId int NOT NULL 
            , DateArchived DateTime
            , CONSTRAINT FK_ArchivedEmail_ScheduledEmailStatus FOREIGN KEY (ScheduledEmailStatusId) REFERENCES ScheduledEmailStatus(Id)
            , CONSTRAINT FK_ArchivedEmail_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
            , CONSTRAINT UNC_ArchivedEmail_ScheduledEmail UNIQUE NONCLUSTERED (ScheduledEmailId)
        );
       
        /*
            Create Table ArchivedEmailTo
        */
        IF OBJECT_ID('dbo.ArchivedEmailTo', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ArchivedEmailTo;
        END

        CREATE TABLE ArchivedEmailTo(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , Name Varchar(100) 
            , Email Varchar(320) 
            , CC Bit
            , BCC Bit
            , CONSTRAINT FK_ArchivedEmailTo_ArchivedEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ArchivedEmail(ScheduledEmailId)
        );
       
        /*
            Create Table ArchivedEmailAttachment
        */
        IF OBJECT_ID('dbo.ArchivedEmailAttachment', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ArchivedEmailAttachment;
        END

        CREATE TABLE ArchivedEmailAttachment(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , FilePath Varchar(200)
            , CONSTRAINT FK_ArchivedEmailAttachment_ArchivedEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ArchivedEmail(ScheduledEmailId)
        );
       
        /*
            Create Table ArchivedEmailNote
        */
        IF OBJECT_ID('dbo.ArchivedEmailNote', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ArchivedEmailNote;
        END

        CREATE TABLE ArchivedEmailNote(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , Note Varchar(1000)
            , CONSTRAINT FK_ArchivedEmailNote_ArchivedEmail FOREIGN KEY (ScheduledEmailId) REFERENCES ArchivedEmail(ScheduledEmailId)
        );
       
        /*
            Create Table EmailService
        */
        IF OBJECT_ID('dbo.EmailService', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.EmailService;
        END

        CREATE TABLE EmailService(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , Name Varchar(100)
            , [Server] Varchar(100)
            , AccessId Varchar(320)
            , AccessPassword Varchar(40)
            , [Disabled] Bit
            , DateLastUsed DateTime
        );
       
        /*
            Create Table EmailServiceNote
        */
        IF OBJECT_ID('dbo.EmailServiceNote', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.EmailServiceNote;
        END

        CREATE TABLE EmailServiceNote(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , EmailServiceId int NOT NULL
            , Note Varchar(1000)
            , CONSTRAINT FK_EmailServiceNote_EmailService FOREIGN KEY (EmailServiceId) REFERENCES EmailService(Id)
        );
       
        /*
            Create Table EmailServiceEmailsSent
        */
        IF OBJECT_ID('dbo.EmailServiceEmailsSent', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.EmailServiceEmailsSent;
        END

        CREATE TABLE EmailServiceEmailsSent(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledEmailId int NOT NULL
            , DateSent DateTime
            , CONSTRAINT UNC_EmailServiceEmailsSent_ScheduledEmail UNIQUE NONCLUSTERED (ScheduledEmailId)
        );
       
        /*
            Create Table EmailServiceEmailCount
        */
        IF OBJECT_ID('dbo.EmailServiceEmailCount', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.EmailServiceEmailCount;
        END

        CREATE TABLE EmailServiceEmailCount(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , YearSent int NOT NULL
            , MonthSent int NOT NULL
            , WeekNumberSent int NOT NULL
            , NumberSent int
            , NumberSentMonday int
            , NumberSentTuesday int
            , NumberSentWednesday int
            , NumberSentThursday int
            , NumberSentFriday int
            , NumberSentSaturday int
            , NumberSentSunday int
        );
       
        /*
            Create Table OrganisationPrefferedEmailService
        */
        IF OBJECT_ID('dbo.OrganisationPrefferedEmailService', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.OrganisationPrefferedEmailService;
        END

        CREATE TABLE OrganisationPrefferedEmailService(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , OrganisationId int NOT NULL
            , EmailServiceId int NOT NULL
            , CONSTRAINT FK_OrganisationPrefferedEmailService_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
            , CONSTRAINT FK_OrganisationPrefferedEmailService_EmailService FOREIGN KEY (EmailServiceId) REFERENCES EmailService(Id)
            , CONSTRAINT UC_OrganisationPrefferedEmailService UNIQUE (OrganisationId, EmailServiceId)
        );
       
        /*
            Create Table ScheduledReport
        */
        IF OBJECT_ID('dbo.ScheduledReport', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledReport;
        END

        CREATE TABLE ScheduledReport(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ReportId int NOT NULL
            , LastSent DateTime
            , NextDue DateTime
            , FrequencyCode Char(1)
            , [Disabled] Bit
            , CONSTRAINT FK_ScheduledReport_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
        );
       
        /*
            Create Table ScheduledReportParameter
        */
        IF OBJECT_ID('dbo.ScheduledReportParameter', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledReportParameter;
        END

        CREATE TABLE ScheduledReportParameter(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledReportId int NOT NULL
            , DataViewColumnId int NOT NULL
            , DataViewColumnValue Varchar(200)
            , CONSTRAINT FK_ScheduledReportParameter_Report FOREIGN KEY (ScheduledReportId) REFERENCES ScheduledReport(Id)
        );
       
        /*
            Create Table ScheduledReportHistory
        */
        IF OBJECT_ID('dbo.ScheduledReportHistory', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledReportHistory;
        END

        CREATE TABLE ScheduledReportHistory(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledReportId int NOT NULL
            , DateSent DateTime
            , CONSTRAINT FK_ScheduledReportHistory_ScheduledReport FOREIGN KEY (ScheduledReportId) REFERENCES ScheduledReport(Id)
        );
       
        /*
            Create Table ScheduledReportEmailTo
        */
        IF OBJECT_ID('dbo.ScheduledReportEmailTo', 'U') IS NOT NULL
        BEGIN
            DROP TABLE dbo.ScheduledReportEmailTo;
        END

        CREATE TABLE ScheduledReportEmailTo(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
            , ScheduledReportId int NOT NULL
            , Name Varchar(100) 
            , Email Varchar(320) 
            , CC Bit
            , BCC Bit
            , CONSTRAINT FK_ScheduledReportEmailTo_ScheduledReport FOREIGN KEY (ScheduledReportId) REFERENCES ScheduledReport(Id)
        );
        
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

