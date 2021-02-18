/*
 * SCRIPT: Add insert trigger to the ReportRequest table
 * Author: Nick Smith
 * Created: 28/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_27.01_CreateInsertTriggerToReportRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the ReportRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_ReportRequest_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_ReportRequest_INSERT];
	END
GO

	CREATE TRIGGER TRG_ReportRequest_INSERT ON ReportRequest FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'ReportRequest', 'TRG_ReportRequest_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			INSERT INTO [dbo].[ReportQueue]
			   ([OrganisationId]
			   ,[CreatedByUserId]
			   ,[DateCreated]
			   ,[DateTimeLastRun]
			   ,[LastRunByUserId])
			SELECT 
				 I.OrganisationId
			   , I.CreatedByUserId
			   , GetDate()
			   , NULL
			   , NULL
			FROM INSERTED I
			LEFT JOIN [dbo].[ReportQueue] RQ
				ON I.OrganisationId = RQ.OrganisationId
					AND I.CreatedByUserId = RQ.CreatedByUserId
			WHERE I.[SendToPrintQueue] = 'True'
					AND RQ.Id IS NULL

		
			INSERT INTO [dbo].[ReportQueueRequest]
			   ([ReportQueueId]
			   ,[ReportRequestId]
			   ,[DateCreated]
			   ,[CreatedByUserId])
			SELECT
				 RQ.Id
			   , I.Id
			   , GetDate()
			   , I.CreatedByUserId
			FROM INSERTED I
			INNER JOIN  [dbo].[ReportQueue] RQ
				ON I.OrganisationId = RQ.OrganisationId
					AND I.CreatedByUserId = RQ.CreatedByUserId

		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_27.01_CreateInsertTriggerToReportRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

