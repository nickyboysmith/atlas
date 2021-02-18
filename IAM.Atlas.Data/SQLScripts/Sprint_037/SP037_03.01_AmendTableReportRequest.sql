/*
 * SCRIPT: Add New Column to Table ReportRequest
 * Author: Robert Newnham
 * Created: 28/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_03.01_AmendTableReportRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table ReportRequest';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReportRequest
		ADD OrganisationId INT NULL
			, CONSTRAINT FK_ReportRequest_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;