/*
	SCRIPT: Create Report Request Tables
	Author: Robert Newnham
	Created: 11/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_06.01_Create_Table_ReportRequestTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Report Request Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportRequestParameter'
		EXEC dbo.uspDropTableContraints 'ReportRequest'
		
		/*
		 *	Create ReportRequest Table
		 */
		IF OBJECT_ID('dbo.ReportRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportRequest;
		END

		CREATE TABLE ReportRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId INT NOT NULL INDEX IX_ReportRequestReportId NONCLUSTERED
			, CreatedByUserId INT NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE() INDEX IX_ReportRequestDateCreated NONCLUSTERED
			, CONSTRAINT FK_ReportRequest_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
			
		/*
		 *	Create ReportRequestParameter Table
		 */
		IF OBJECT_ID('dbo.ReportRequestParameter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportRequestParameter;
		END

		CREATE TABLE ReportRequestParameter(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportRequestId INT NOT NULL INDEX IX_ReportRequestParameterReportRequestId NONCLUSTERED
			, ReportParameterId INT NOT NULL INDEX IX_ReportRequestParameterReportParameterId NONCLUSTERED
			, ParameterValue VARCHAR(200)
			, CONSTRAINT FK_ReportRequestParameter_ReportRequest FOREIGN KEY (ReportRequestId) REFERENCES ReportRequest(Id)
			, CONSTRAINT FK_ReportRequestParameter_ReportParameter FOREIGN KEY (ReportParameterId) REFERENCES ReportParameter(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;