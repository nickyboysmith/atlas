
/*
	SCRIPT: Create Table to Hold Dashboard Meter View for Documents Statistics
	Author: Robert Newnham
	Created: 27/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_09.01_CreateTableDashboardMeter_DocumentStats.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table to Hold Dashboard Meter View for Documents Statistics';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeter_DocumentSummary'
		
		/*
		 *	Create DashboardMeter_DocumentSummary Table
		 */
		IF OBJECT_ID('dbo.DashboardMeter_DocumentSummary', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeter_DocumentSummary;
		END
		
		CREATE TABLE DashboardMeter_DocumentSummary(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT 
			, NumberOfDocuments BIGINT 
			, TotalSize BIGINT
			, NumberOfDocumentsThisMonth BIGINT
			, TotalSizeOfDocumentsThisMonth BIGINT
			, NumberOfDocumentsPreviousMonth BIGINT
			, TotalSizeOfDocumentsPreviousMonth BIGINT
			, NumberOfDocumentsThisYear BIGINT
			, TotalSizeOfDocumentsThisYear BIGINT
			, NumberOfDocumentsPreviousYear BIGINT
			, TotalSizeOfDocumentsPreviousYear BIGINT
			, NumberOfDocumentsPreviousTwoYears BIGINT
			, TotalSizeOfDocumentsPreviousTwoYears BIGINT
			, NumberOfDocumentsPreviousThreeYears BIGINT
			, TotalSizeOfDocumentsPreviousThreeYears BIGINT
			, CONSTRAINT FK_DashboardMeter_DocumentSummary_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;