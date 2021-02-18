/*
	SCRIPT: Create a function to return True or False if the Report Schedule is Disabled
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.06_CreateFunctionIsReportScheduleDisabled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return True or False if the Report Schedule is Disabled';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfIsReportScheduleDisabled', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfIsReportScheduleDisabled;
	END		
	GO

	/*
		Create udfIsReportScheduleDisabled
	*/
	CREATE FUNCTION udfIsReportScheduleDisabled ()
	RETURNS BIT
	AS
	BEGIN
		DECLARE @udfIsReportScheduleDisabled bit = 'False';
		SELECT @udfIsReportScheduleDisabled=[ReportScheduleDisabled] FROM [dbo].[SchedulerControl] WHERE Id = 1;

		RETURN @udfIsReportScheduleDisabled;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.06_CreateFunctionIsReportScheduleDisabled.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





