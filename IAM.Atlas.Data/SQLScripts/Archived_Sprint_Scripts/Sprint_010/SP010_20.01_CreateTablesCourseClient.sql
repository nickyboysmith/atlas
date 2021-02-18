/*
	SCRIPT: Create Course Client Tables
	Author: Paul Tuck
	Created: 16/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_20.01_CreateTablesCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creates tables used to store a course''s allocated clients';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseClient'
			EXEC dbo.uspDropTableContraints 'CourseClientPayment'
			EXEC dbo.uspDropTableContraints 'CourseClientRemoved'
		
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.CourseClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClient;
		END
		
		IF OBJECT_ID('dbo.CourseClientPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientPayment;
		END
		
		IF OBJECT_ID('dbo.CourseClientRemoved', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientRemoved;
		END
		
		/*
			Create Table SearchHistoryInterface
		*/
		CREATE TABLE CourseClient(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, ClientId int NOT NULL
			, DateAdded Datetime NOT NULL
			, AddedByUserId int NOT NULL
			, CONSTRAINT FK_CourseClientCourseId_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientClientId_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientAddedByUserId_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		
		/*
			Create Table SearchHistoryUser
		*/
		CREATE TABLE CourseClientPayment(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, ClientId int NOT NULL
			, PaymentId int NOT NULL
			, CONSTRAINT FK_CourseClientPaymentCourseId_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientPaymentClientId_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientPaymentPaymentId_Payment FOREIGN KEY (PaymentId) REFERENCES [Payment](Id)
		);
		
		/*
			Create Table SearchHistoryItem
		*/
		CREATE TABLE CourseClientRemoved(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, ClientId INT NOT NULL
			, DateRemoved DATETIME NOT NULL
			, RemovedByUserId INT NOT NULL
			, CONSTRAINT FK_CourseClientRemovedCourseId_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientRemovedClientId_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientRemovedRemovedByUserId_User FOREIGN KEY (RemovedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


