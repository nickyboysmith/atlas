/*
	SCRIPT: Create uspUpdateLastRunLog
	Author: Robert Newnham
	Created: 07/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_17.01_Create_SP_uspUpdateLastRunLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspUpdateLastRunLog SP';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateLastRunLog', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateLastRunLog;
END		
GO
	/*
		Create uspUpdateLastRunLog
	*/

	CREATE PROCEDURE [dbo].[uspUpdateLastRunLog] 
		(
		@ProcessName VARCHAR(100)
		, @ErrorMessage VARCHAR(2000) = NULL
		)
	AS
	BEGIN
		INSERT INTO [dbo].[LastRunLog] (ItemName, ItemDescription, DateLastRun, DateCreated, DateLastRunError, LastRunError)
		SELECT ItemName, ItemDescription, DateLastRun, DateCreated, DateLastRunError, LastRunError
		FROM (
			SELECT @ProcessName AS ItemName
				, @ProcessName AS ItemDescription
				, GETDATE() AS DateLastRun
				, GETDATE() AS DateCreated
				, (CASE WHEN @ErrorMessage IS NULL 
						THEN NULL ELSE GETDATE() END)	AS DateLastRunError
				, @ErrorMessage AS LastRunError
			) T
		WHERE NOT EXISTS (SELECT * FROM [dbo].[LastRunLog] L WHERE L.ItemName = T.ItemName);

		UPDATE [dbo].[LastRunLog]
		SET DateLastRun = GETDATE()
		, DateLastRunError = (CASE WHEN @ErrorMessage IS NULL 
									THEN DateLastRunError ELSE GETDATE() END)
		, LastRunError = (CASE WHEN @ErrorMessage IS NULL 
								THEN LastRunError ELSE @ErrorMessage END)
		WHERE ItemName = @ProcessName;
		;

	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP037_17.01_Create_SP_uspUpdateLastRunLog.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO