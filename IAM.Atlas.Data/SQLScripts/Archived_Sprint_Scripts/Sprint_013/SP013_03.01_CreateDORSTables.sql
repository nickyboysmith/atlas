


/*
	SCRIPT: Create DORS Tables
	Author: NickSmith
	Created: 08/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_03.01_CreateDORSTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORS Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSState'

		/*
			Create Table DORSState
		*/
		IF OBJECT_ID('dbo.DORSState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSState;
		END

		CREATE TABLE DORSState(
			Id int PRIMARY KEY NOT NULL
			, Name Varchar(100) NOT NULL
			, [Description] Varchar(400)
			, SystemStateId int DEFAULT 0
			, CONSTRAINT FK_DORSState_SystemState FOREIGN KEY (SystemStateId) REFERENCES [SystemState](Id)
		);
		
		IF OBJECT_ID('dbo.DORSState', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId) VALUES (0, 'Unknown', 'Unknown', 2)
			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId) VALUES (1, 'Normal', 'DORS is operating as expected', 1)
			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId) VALUES (2, 'Error1', 'DORS is running but has reported an error', 3)
			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId) VALUES (3, 'Disabled', 'DORS has been disabled', 4)
			INSERT INTO dbo.DORSState(Id, Name, [Description], SystemStateId) VALUES (4, 'Error2', 'DORS has reported an error and is not running', 4)

		END


		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSControl'

		/*
			Create Table DORSControl
		*/
		IF OBJECT_ID('dbo.DORSControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSControl;
		END

		CREATE TABLE DORSControl(
			Id int PRIMARY KEY NOT NULL
			, DORSEnabled bit NOT NULL DEFAULT 1
			, PasswordExpiryDays int NOT NULL
			, DORSStateId int 
			, CONSTRAINT FK_DORSControl_DORSState FOREIGN KEY (DORSStateId) REFERENCES DORSState(Id)
		);
		
		IF OBJECT_ID('dbo.DORSControl', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.DORSControl(Id, PasswordExpiryDays, DORSStateId) VALUES (1, 35, 0)
		END

		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSConnection'

		/*
			Create Table DORSControl
		*/
		IF OBJECT_ID('dbo.DORSConnection', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnection;
		END

		CREATE TABLE DORSConnection(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserName Varchar(100) NOT NULL
			, [Password] Varchar(100) NOT NULL
			, OrganisationId int NOT NULL
			, [Enabled] bit DEFAULT 1
			, PasswordLastChanged DateTime
			, CONSTRAINT FK_DORSConnection_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSConnectionNotificationEmail'

		/*
			Create Table DORSConnectionNotificationEmail
		*/
		IF OBJECT_ID('dbo.DORSConnectionNotificationEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionNotificationEmail;
		END

		CREATE TABLE DORSConnectionNotificationEmail(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSConnectionId int NOT NULL
			, EmailId int NOT NULL
			, CONSTRAINT FK_DORSConnectionNotificationEmail_DORSConnection FOREIGN KEY (DORSConnectionId) REFERENCES DORSConnection(Id)
			, CONSTRAINT FK_DORSConnectionNotificationEmail_Email FOREIGN KEY (EmailId) REFERENCES Email(Id)
		);
		
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSLicenceCheckRequest'

		/*
			Create Table DORSLicenceCheckRequest
		*/
		IF OBJECT_ID('dbo.DORSLicenceCheckRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSLicenceCheckRequest;
		END

		CREATE TABLE DORSLicenceCheckRequest(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, LicenceNumber Varchar(40) NOT NULL
			, RequestByUserId int
			, Requested DateTime
			, CONSTRAINT FK_DORSLicenceCheckRequest_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_DORSLicenceCheckRequest_User FOREIGN KEY (RequestByUserId) REFERENCES [User](Id)
		);
			
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSAttendanceState'

		/*
			Create Table DORSAttendanceState
		*/
		IF OBJECT_ID('dbo.DORSAttendanceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSAttendanceState;
		END

		CREATE TABLE DORSAttendanceState(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(100) NOT NULL
			, [Description] Varchar(400)
		);
		
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSLicenceCheckCompleted'

		/*
			Create Table DORSLicenceCheckCompleted
		*/
		IF OBJECT_ID('dbo.DORSLicenceCheckCompleted', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSLicenceCheckCompleted;
		END

		CREATE TABLE DORSLicenceCheckCompleted(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, LicenceNumber Varchar(40) NOT NULL
			, RequestByUserId int
			, Requested DateTime 
			, Completed DateTime
			, DORSAttendanceStateId int
			, DORSAttendanceRef int
			, [SessionId]  int CONSTRAINT ux_DORSLicenceCheckCompleted_SessionId UNIQUE NONCLUSTERED
			, CONSTRAINT FK_DORSLicenceCheckCompleted_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_DORSLicenceCheckCompleted_User FOREIGN KEY (RequestByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_DORSLicenceCheckCompleted_DORSAttendanceState FOREIGN KEY (DORSAttendanceStateId) REFERENCES [DORSAttendanceState](Id)
		);
		
		
		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'DORSClientCourseAttendance'

		/*
			Create Table DORSClientCourseAttendance
		*/
		IF OBJECT_ID('dbo.DORSClientCourseAttendance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSClientCourseAttendance;
		END

		CREATE TABLE DORSClientCourseAttendance(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int 
			, CourseId int 
			, Attended bit NOT NULL
			, Completed bit NOT NULL
			, DORSAttendanceRef int 
			, DateCreated DateTime NOT NULL DEFAULT GetDate()
			, CONSTRAINT FK_DORSClientCourseAttendance_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_DORSClientCourseAttendance_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);
		
		/* 
		TODO above DorsAttendanceid is foreign constrain to DORSAttendanceState ?
		*/
		
		
		
		/*
		Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'DORSTransactionHistory'
			

		/*
			Create Table DORSTransactionHistory
		*/
		IF OBJECT_ID('dbo.DORSTransactionHistory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTransactionHistory;
		END

		CREATE TABLE DORSTransactionHistory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateTimeCreated DateTime NOT NULL DEFAULT GetDate()
			, Title Varchar(100) NOT NULL
			, Detail Varchar(400) NOT NULL
			, AssociatedUserId int
			, CONSTRAINT FK_DORSTransactionHistory_User FOREIGN KEY (AssociatedUserId) REFERENCES [User](Id)
		);
			
		/*
		Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'DORSAttendanceLog'
		/*
			Create Table DORSTransactionHistory
		*/
		IF OBJECT_ID('dbo.DORSAttendanceLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSAttendanceLog;
		END

		CREATE TABLE DORSAttendanceLog(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title Varchar(200) NOT NULL
			, Detail Varchar(400) 
			, DORSAttendanceRef int
			, CourseId int
			, AssociatedDate DateTime
			, DateCreated DateTime NOT NULL DEFAULT GetDate()
			, Comments Varchar(1000) 
			, CONSTRAINT FK_DORSAttendanceLog_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			
		);
		
		/* 
		TODO above Attendanceid is foreign constrain to DORSClientCourseAttendance NOT State ?
		*/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

