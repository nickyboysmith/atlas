/*
	SCRIPT: Create a function to return the First of the Monthe Date From Any Date/DateTime
	Author: Robert Newnham
	Created: 28/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_06.01_CreateFunctionudfReturnFirstOfMonthDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return the First of the Monthe Date From Any Date/DateTime';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfReturnFirstOfMonthDate', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfReturnFirstOfMonthDate;
	END		
	GO

	/*
		Create udfReturnFirstOfMonthDate
	*/
	CREATE FUNCTION dbo.udfReturnFirstOfMonthDate (@theDate AS DATETIME)
	RETURNS DATE
	AS
	BEGIN
		DECLARE @TheNewDate AS DATE;
		
		SELECT @TheNewDate = DATEADD(DAY,1,EOMONTH(@theDate,-1));

		RETURN @TheNewDate;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP034_06.01_CreateFunctionudfReturnFirstOfMonthDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





