/*
	SCRIPT: Create Stored Procedure uspRecordInProcessMonitor
	Author: Robert Newnham
	Created: 07/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_35.01_Create_SP_uspRecordInProcessMonitor.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspRecordInProcessMonitor';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRecordInProcessMonitor', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRecordInProcessMonitor;
END		
GO

	/*
		Create uspRecordInProcessMonitor
	*/

	CREATE PROCEDURE dbo.uspRecordInProcessMonitor (
		@ProcessName VARCHAR(200)
		, @ProcessIdentifier INT
		, @ProcessComments VARCHAR(1000) = NULL
	)
	AS
	BEGIN
		INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
		VALUES (GETDATE()
				, @ProcessName
				, @ProcessIdentifier
				, @ProcessComments
				);
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP028_35.01_Create_SP_uspRecordInProcessMonitor.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; 
GO