/*
	SCRIPT: Create a function to return True or False if the Email Schedule is Disabled
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.05_CreateFunctionIsEmailScheduleDisabled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return True or False if the Email Schedule is Disabled';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfIsEmailScheduleDisabled', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfIsEmailScheduleDisabled;
	END		
	GO

	/*
		Create udfIsEmailScheduleDisabled
	*/
	CREATE FUNCTION udfIsEmailScheduleDisabled ()
	RETURNS BIT
	AS
	BEGIN
		DECLARE @udfIsEmailScheduleDisabled bit = 'False';
		SELECT @udfIsEmailScheduleDisabled=[EmailScheduleDisabled] FROM [dbo].[SchedulerControl] WHERE Id = 1;

		RETURN @udfIsEmailScheduleDisabled;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.05_CreateFunctionIsEmailScheduleDisabled.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





