
/*
	SCRIPT: Returns Date with UK Time
	Author: Robert Newnham
	Created: 12/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_12.01_CreateFunction_udfGetDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Returns Date with UK Time';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetDate', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetDate;
	END		
	GO
	
	/*
		Create udfGetDate
	*/
	CREATE FUNCTION [dbo].udfGetDate ()
	RETURNS DATETIME
	AS
	BEGIN
		DECLARE @GetDate DateTime = DATEADD(HOUR, DATEDIFF(HOUR, GETDATE() AT TIME ZONE 'GMT Standard Time', GETDATE()), GETDATE())
		RETURN @GetDate;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP043_12.01_CreateFunction_udfGetDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO