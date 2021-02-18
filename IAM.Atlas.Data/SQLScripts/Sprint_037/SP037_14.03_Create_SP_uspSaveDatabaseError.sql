/*
	SCRIPT: Create Stored procedure uspSaveDatabaseError
	Author: Robert Newnham
	Created: 05/05/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_14.03_Create_SP_uspSaveDatabaseError.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspSaveDatabaseError';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSaveDatabaseError', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSaveDatabaseError;
END		
GO
	/*
		Create uspSaveDatabaseError
	*/
	
	CREATE PROCEDURE [dbo].[uspSaveDatabaseError] 
		(
		@ProcedureName VARCHAR(200)
		, @ErrorMessage VARCHAR(4000)
		, @ErrorNumber INT = NULL
		, @ErrorSeverity INT = NULL
		, @ErrorState INT = NULL
		, @ErrorProcedure VARCHAR(140) = NULL
		, @ErrorLine INT = NULL
		)
	AS
	BEGIN
		
		INSERT INTO dbo.DatabaseErrorLog (
			DateAndTimeRecorded
			, ProcedureName
			, ErrorNumber
			, ErrorSeverity
			, ErrorState
			, ErrorProcedure
			, ErrorLine
			, ErrorMessage
			)
		VALUES (
			GETDATE()
			, @ProcedureName
			, @ErrorNumber
			, @ErrorSeverity
			, @ErrorState
			, @ErrorProcedure
			, @ErrorLine
			, @ErrorMessage
			);
	END
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP037_14.03_Create_SP_uspSaveDatabaseError.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
