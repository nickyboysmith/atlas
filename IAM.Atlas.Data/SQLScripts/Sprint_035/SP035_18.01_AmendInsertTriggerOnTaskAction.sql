/*
	SCRIPT: Amend Insert trigger on TaskAction
	Author: Paul Tuck
	Created: 24/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_18.01_AmendInsertTriggerOnTaskAction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on TaskAction';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_TaskAction_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_TaskAction_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_TaskAction_INSERT] ON [dbo].[TaskAction] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'TaskAction', 'TRG_TaskAction_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			BEGIN
				EXEC uspEnsureTaskActionForOrganisation;
			END

			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_18.01_AmendInsertTriggerOnTaskAction.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO