/*
	SCRIPT: Create Insert and Update Trigger To DashboardMeter
	Author: Robert Newnham
	Created: 06/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_10.03_CreateInsertUpdateTriggerToDashboardMeter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert and Update Trigger To DashboardMeter';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_DashboardMeter_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_DashboardMeter_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_DashboardMeter_InsertUpdate ON dbo.DashboardMeter AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DashboardMeter', 'TRG_DashboardMeter_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			UPDATE DM
			SET DM.DashboardMeterCategoryId = (SELECT TOP 1 Id FROM [dbo].[DashboardMeterCategory] WHERE DefaultCategory = 'True')
			FROM INSERTED I
			INNER JOIN DashboardMeter DM ON DM.Id = I.Id
			WHERE I.DashboardMeterCategoryId IS NULL;
			
			/****************************************************************************************************************/

		END --END PROCESS
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP034_10.03_CreateInsertUpdateTriggerToDashboardMeter.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	