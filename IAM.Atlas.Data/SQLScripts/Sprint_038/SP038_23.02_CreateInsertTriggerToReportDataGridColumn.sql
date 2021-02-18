/*
 * SCRIPT: Add insert trigger to the ReportDataGridColumn table
 * Author: Robert Newnham
 * Created: 05/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_23.02_CreateInsertTriggerToReportDataGridColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the ReportDataGridColumn table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_ReportDataGridColumn_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_ReportDataGridColumn_INSERT];
	END
GO

	CREATE TRIGGER TRG_ReportDataGridColumn_INSERT ON ReportDataGridColumn FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'ReportDataGridColumn', 'TRG_ReportDataGridColumn_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE RDGC
			SET RDGC.[ColumnTitle] = DVC.Title
			FROM INSERTED I
			INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.Id = I.Id
			INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.Id = RDGC.DataViewColumnId
			WHERE LEN(ISNULL(I.[ColumnTitle],'')) <= 0;

		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_23.02_CreateInsertTriggerToReportDataGridColumn.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

