/*
	SCRIPT: Create SMS Tables
	Author: Miles Stewart
	Created: 29/01/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_11.01_CreateSMSTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SMS Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/**
		 * Drop constraints if they exist
		 */
		 EXEC dbo.uspDropTableContraints 'OrganisationPreferredSMSService'
		 EXEC dbo.uspDropTableContraints 'SMSServiceMessagesSent'
		 EXEC dbo.uspDropTableContraints 'SMSServiceNote'
		 EXEC dbo.uspDropTableContraints 'ArchivedSMSNote'
		 EXEC dbo.uspDropTableContraints 'ArchivedSMSToList'
		 EXEC dbo.uspDropTableContraints 'ArchivedSMSToList'
		 EXEC dbo.uspDropTableContraints 'ArchivedSMS'
		 EXEC dbo.uspDropTableContraints 'ScheduledSMSNote'
		 EXEC dbo.uspDropTableContraints 'ScheduledSMSTo'
		 EXEC dbo.uspDropTableContraints 'ScheduledSMS'


		/*
		 *	Create ScheduledSMSStatus Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMSStatus', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMSStatus;
		END

		CREATE TABLE ScheduledSMSStatus(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100)
		);

		/*
		 *	Create ScheduledSMS Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMS;
		END

		CREATE TABLE ScheduledSMS(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Content varchar(400)
			, DateCreated DATETIME DEFAULT GETDATE()
			, ScheduledSMSStatusId int
			, DateSent DATETIME DEFAULT GETDATE()
			, [Disabled] bit DEFAULT 0
			, [ASAP] bit DEFAULT 0
			, SendAfterDate DATETIME
			, OrganisationId int NULL
			, CONSTRAINT FK_ScheduledSMS_ScheduledSMSStatus FOREIGN KEY (ScheduledSMSStatusId) REFERENCES [ScheduledSMSStatus](Id)
			, CONSTRAINT FK_ScheduledSMS_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		/*
		 *	Create ScheduledSMSTo Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMSTo', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMSTo;
		END

		CREATE TABLE ScheduledSMSTo(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, PhoneNumber varchar(20)
			, IdentifyingName varchar(320)
			, IdentifyingId int
			, IdType varchar(40)
			, CONSTRAINT FK_ScheduledSMSTo_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);

		/*
		 *	Create ScheduledSMSNote Table
		 */
		IF OBJECT_ID('dbo.ScheduledSMSNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledSMSNote;
		END

		CREATE TABLE ScheduledSMSNote(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, Note varchar(1000)
			, CONSTRAINT FK_ScheduledSMSNote_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);

		/*
		 *	Create ArchivedSMS Table
		 */
		IF OBJECT_ID('dbo.ArchivedSMS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ArchivedSMS;
		END

		CREATE TABLE ArchivedSMS(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, Content varchar(400)
			, DateCreated DATETIME
			, ScheduledSMSStatusId int
			, DateSent DATETIME DEFAULT GETDATE()
			, [Disabled] bit DEFAULT 0
			, [ASAP] bit DEFAULT 0
			, SendAfterDate DATETIME
			, OrganisationId int NULL
			, DateArchived DATETIME
			, CONSTRAINT FK_ArchivedSMS_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
			, CONSTRAINT FK_ArchivedSMS_ScheduledSMSStatus FOREIGN KEY (ScheduledSMSStatusId) REFERENCES [ScheduledSMSStatus](Id)
			, CONSTRAINT FK_ArchivedSMS_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		/*
		 *	Create ArchivedSMSToList Table
		 */
		IF OBJECT_ID('dbo.ArchivedSMSToList', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ArchivedSMSToList;
		END

		CREATE TABLE ArchivedSMSToList(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, PhoneNumber varchar(20)
			, CONSTRAINT FK_ArchivedSMSToList_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);

		/*
		 *	Create ArchivedSMSNote Table
		 */
		IF OBJECT_ID('dbo.ArchivedSMSNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ArchivedSMSNote;
		END

		CREATE TABLE ArchivedSMSNote(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, Note varchar(1000)
			, CONSTRAINT FK_ArchivedSMSNote_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);

		/*
		 *	Create SMSService Table
		 */
		IF OBJECT_ID('dbo.SMSService', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSService;
		END

		CREATE TABLE SMSService(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100)
			, [Disabled] bit DEFAULT 0
			, DateLastUsed DATETIME
		);

		/*
		 *	Create SMSServiceNote Table
		 */
		IF OBJECT_ID('dbo.SMSServiceNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSServiceNote;
		END

		CREATE TABLE SMSServiceNote(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SMSServiceId int
			, Note varchar(1000)
			, CONSTRAINT FK_SMSServiceNote_SMSService FOREIGN KEY (SMSServiceId) REFERENCES [SMSService](Id)
		);

		/*
		 *	Create SMSServiceMessagesSent Table
		 */
		IF OBJECT_ID('dbo.SMSServiceMessagesSent', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSServiceMessagesSent;
		END

		CREATE TABLE SMSServiceMessagesSent(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledSMSId int
			, DateSent DATETIME DEFAULT GETDATE()
			, CONSTRAINT FK_SMSServiceMessagesSent_ScheduledSMS FOREIGN KEY (ScheduledSMSId) REFERENCES [ScheduledSMS](Id)
		);
		
		/*
		 *	Create SMSServiceMessageCount Table
		 */
		IF OBJECT_ID('dbo.SMSServiceMessageCount', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSServiceMessageCount;
		END

		CREATE TABLE SMSServiceMessageCount(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, YearSent int
			, MonthSent int
			, WeekNumberSent int
			, NumberSent int
		);
				
		/*
		 *	Create OrganisationPreferredSMSService Table
		 */
		IF OBJECT_ID('dbo.OrganisationPreferredSMSService', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationPreferredSMSService;
		END

		CREATE TABLE OrganisationPreferredSMSService(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int
			, SMSServiceId int
			, CONSTRAINT FK_OrganisationPreferredSMSService_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_OrganisationPreferredSMSService_SMSService FOREIGN KEY (SMSServiceId) REFERENCES [SMSService](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;