/*
	SCRIPT: Create a function to return True or False if the Archive Schedule is Disabled
	Author: Robert Newnham
	Created: 11/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_32.07_CreateFunctionIsArchiveScheduleDisabled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return True or False if the Archive Schedule is Disabled';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfIsArchiveScheduleDisabled', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfIsArchiveScheduleDisabled;
	END		
	GO

	/*
		Create udfIsArchiveScheduleDisabled
	*/
	CREATE FUNCTION udfIsArchiveScheduleDisabled ()
	RETURNS BIT
	AS
	BEGIN
		DECLARE @udfIsArchiveScheduleDisabled bit = 'False';
		SELECT @udfIsArchiveScheduleDisabled=[ArchiveScheduleDisabled] FROM [dbo].[SchedulerControl] WHERE Id = 1;

		RETURN @udfIsArchiveScheduleDisabled;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.07_CreateFunctionIsArchiveScheduleDisabled.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





