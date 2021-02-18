/*
	SCRIPT: Create Report Queue Tables
	Author: Robert Newnham
	Created: 14/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_10.02_CreateReportQueueTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table ReportRequest';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportQueueRequest'
		EXEC dbo.uspDropTableContraints 'ReportQueue'
		
		/*
		 *	Create ReportQueue Table
		 */
		IF OBJECT_ID('dbo.ReportQueue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportQueue;
		END

		CREATE TABLE ReportQueue(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_ReportQueueOrganisationId NONCLUSTERED
			, CreatedByUserId INT NOT NULL INDEX IX_ReportQueueCreatedByUserId NONCLUSTERED
			, DateCreated DateTime NOT NULL DEFAULT GETDATE()
			, DateTimeLastRun DateTime NULL
			, LastRunByUserId INT NULL INDEX IX_ReportQueueLastRunByUserId NONCLUSTERED
			, CONSTRAINT FK_ReportQueue_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_ReportQueue_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ReportQueue_User_LastRunByUserId FOREIGN KEY (LastRunByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportQueueRequest'
		
		/*
		 *	Create ReportQueueRequest Table
		 */
		IF OBJECT_ID('dbo.ReportQueueRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportQueueRequest;
		END

		CREATE TABLE ReportQueueRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportQueueId INT NOT NULL INDEX IX_ReportQueueRequestReportQueueId NONCLUSTERED
			, ReportRequestId INT NOT NULL INDEX IX_ReportQueueRequestReportRequestId NONCLUSTERED
			, DateCreated DateTime NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL INDEX IX_ReportQueueRequestCreatedByUserId NONCLUSTERED
			, CONSTRAINT FK_ReportQueueRequest_ReportQueue FOREIGN KEY (ReportQueueId) REFERENCES ReportQueue(Id)
			, CONSTRAINT FK_ReportQueueRequest_ReportRequest FOREIGN KEY (ReportRequestId) REFERENCES ReportRequest(Id)
			, CONSTRAINT FK_ReportQueueRequest_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END