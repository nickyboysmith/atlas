/*
	SCRIPT: Create a function to return The DORS Attendance Status Identifier from the Name
	Author: Robert Newnham
	Created: 18/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_38.01_CreateFunctionGetDORSAttendanceStateIdentifier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return The DORS Attendance Status Identifier from the Name';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetDORSAttendanceStateIdentifier', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetDORSAttendanceStateIdentifier;
	END		
	GO

	/*
		Create udfGetDORSAttendanceStateIdentifier
	*/
	CREATE FUNCTION udfGetDORSAttendanceStateIdentifier ( @DORSAttendanceStateIdentifierName VARCHAR(100) )
	RETURNS int
	AS
	BEGIN
		DECLARE @DORSAttendanceStateIdentifier int = -1;
		SELECT @DORSAttendanceStateIdentifier=[DORSAttendanceStateIdentifier]
		FROM [dbo].[DORSAttendanceState]
		WHERE [Name] = @DORSAttendanceStateIdentifierName;

		SET @DORSAttendanceStateIdentifierName = ISNULL(@DORSAttendanceStateIdentifier,-1);

		RETURN @DORSAttendanceStateIdentifier;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_38.01_CreateFunctionGetDORSAttendanceStateIdentifier.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





