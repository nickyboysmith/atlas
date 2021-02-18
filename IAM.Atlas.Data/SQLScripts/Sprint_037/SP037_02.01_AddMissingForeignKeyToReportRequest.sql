/*
	SCRIPT: Create Missing Foreign Key on ReportRequest
	Author: Dan Hough
	Created: 27/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_02.01_AddMissingForeignKeyToReportRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_ReportRequest_Report')
				   AND parent_object_id = OBJECT_ID(N'dbo.ReportRequest')
		)
		BEGIN
			ALTER TABLE ReportRequest DROP CONSTRAINT FK_ReportRequest_Report;
		END
		
		ALTER TABLE ReportRequest
		ADD CONSTRAINT FK_ReportRequest_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;