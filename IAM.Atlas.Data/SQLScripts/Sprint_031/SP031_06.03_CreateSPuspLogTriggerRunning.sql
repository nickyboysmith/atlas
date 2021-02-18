/*
	SCRIPT: Create stored procedure uspLogTriggerRunning
	Author: Robert Newnham
	Created: 28/12/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_06.03_CreateSPuspLogTriggerRunning.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspLogTriggerRunning';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspLogTriggerRunning', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspLogTriggerRunning;
	END		
	GO

	/*
		Create uspLogTriggerRunning
	*/
	CREATE PROCEDURE [dbo].uspLogTriggerRunning (
		@TableName VARCHAR(1000)
		, @TriggerName VARCHAR(1000)
		, @InsertedTableRows INT = NULL
		, @DeletedTableRows INT = NULL
		)
	AS
	BEGIN
		DECLARE @runTrigger BIT = 'False';
		SELECT @runTrigger = LogTriggersRunning FROM SystemControl WHERE Id = 1;
		IF (@runTrigger = 'True')
		BEGIN
			INSERT INTO [dbo].[TriggerLog] (DateTimeRun, TableName, TriggerName, InsertedTableRows, DeletedTableRows)
			VALUES (
				GETDATE()
				, @TableName
				, @TriggerName
				, @InsertedTableRows
				, @DeletedTableRows
			);
		END
	END

	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP031_06.03_CreateSPuspLogTriggerRunning.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO