/*
	SCRIPT: Amend Update trigger on Reconciliation
	Author: Paul Tuck
	Created: 07/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_15.02_CreateUpdateTrigger_Reconciliation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update Trigger on Reconciliation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Reconciliation_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Reconciliation_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Reconciliation_UPDATE] ON [dbo].[Reconciliation] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Reconciliation', 'TRG_Reconciliation_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			BEGIN
				DECLARE @refresh BIT = 'false';
				DECLARE @ReconciliationId INT = NULL;
				
				SELECT @refresh = RefreshPaymentData, @ReconciliationId = I.Id
				FROM Inserted I;

				IF @refresh = 'true'
				BEGIN
					EXEC uspRefreshReconciliationData @ReconciliationId;
				END
				
			END
			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP045_15.02_CreateUpdateTrigger_Reconciliation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO