/*
	SCRIPT: Create a function to return True or False if the SMS Schedule is Disabled
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.08_CreateFunctionIsSMSScheduleDisabled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return True or False if the SMS Schedule is Disabled';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfIsSMSScheduleDisabled', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfIsSMSScheduleDisabled;
	END		
	GO

	/*
		Create udfIsSMSScheduleDisabled
	*/
	CREATE FUNCTION udfIsSMSScheduleDisabled ()
	RETURNS BIT
	AS
	BEGIN
		DECLARE @udfIsSMSScheduleDisabled bit = 'False';
		SELECT @udfIsSMSScheduleDisabled=[SMSScheduleDisabled] FROM [dbo].[SchedulerControl] WHERE Id = 1;

		RETURN @udfIsSMSScheduleDisabled;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.08_CreateFunctionIsSMSScheduleDisabled.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





