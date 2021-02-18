/*
	SCRIPT: Create Update trigger on the SchedulerControl table
	Author: Robert Newnham, made in to a script by Dan Hough
	Created: 22/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_15.01_CreateUpdateTriggerOnSchedulerControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on the SchedulerControl table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_SchedulerControl_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_SchedulerControl_UPDATE;
		END
GO


  CREATE TRIGGER [dbo].[TRG_SchedulerControl_UPDATE] ON [dbo].[SchedulerControl] FOR UPDATE
       AS     
              DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
              DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
              IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
              BEGIN  
                     EXEC uspLogTriggerRunning 'SchedulerControl', 'TRG_SchedulerControl_UPDATE', @insertedRows, @deletedRows;
                     -------------------------------------------------------------------------------------------
                     DECLARE @EmailCode CHAR(4) = 'EM01'
                                  , @ReportCode CHAR(4) = 'RP01'
                                  , @ArchiveCode CHAR(4) = 'AR01'
                                  , @SMSCode CHAR(4) = 'SM01'
                                  , @ArchiveCode2 CHAR(4) = 'AR02' --Email
                                  , @ArchiveCode3 CHAR(4) = 'AR03' --SMS
                                  , @controlKey INT = 1
                                  ;
                     DELETE [dbo].[SystemStateSummary]
                     WHERE CODE IN (@EmailCode, @ReportCode, @ArchiveCode, @SMSCode);
              
                     IF OBJECT_ID('tempdb..#SchedControl', 'U') IS NOT NULL
                     BEGIN
                           DROP TABLE #SchedControl;
                     END

                     SELECT *
                     INTO #SchedControl
                     FROM (
                           SELECT @EmailCode AS Code
                                  , (CASE WHEN [EmailScheduleDisabled] = 'True' 
                                                THEN 'Email Scheduler Disabled'
                                                ELSE 'Email Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [EmailScheduleDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           UNION 
                           SELECT @ReportCode AS Code
                                  , (CASE WHEN [ReportScheduleDisabled] = 'True' 
                                                THEN 'Report Scheduler Disabled'
                                                ELSE 'Report Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [ReportScheduleDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           UNION 
                           SELECT @ArchiveCode AS Code
                                  , (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
                                                THEN 'Archive Scheduler Disabled'
                                                ELSE 'Archive Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           UNION 
                           SELECT @SMSCode AS Code
                                  , (CASE WHEN [SMSScheduleDisabled] = 'True' 
                                                THEN 'SMS Scheduler Disabled'
                                                ELSE 'SMS Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [SMSScheduleDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           UNION 
                           SELECT @ArchiveCode2 AS Code
                                  , (CASE WHEN [EmailArchiveDisabled] = 'True' 
                                                THEN 'Email Archive Scheduler Disabled'
                                                ELSE 'Email Archive Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [EmailArchiveDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           UNION 
                           SELECT @ArchiveCode3 AS Code
                                  , (CASE WHEN [SMSArchiveDisabled] = 'True' 
                                                THEN 'SMS Archive Scheduler Disabled'
                                                ELSE 'SMS Archive Scheduler Running'
                                                END)                              AS [Message]
                                  , (CASE WHEN [SMSArchiveDisabled] = 'True' 
                                                THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
                                                ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
                                                END)                              AS [SystemStateId]
                                  , GetDate()                                     AS [DateUpdated]
                                  , [dbo].[udfGetSystemUserId]()    AS [UpdatedByUserId]
                                  , NULL                                          AS OrganisationId
                           FROM [dbo].[SchedulerControl] SC 
                           WHERE SC.Id = @controlKey
                           ) SchedControl;

                     DELETE SSSH
                     FROM SystemStateSummaryHistory SSSH
                     INNER JOIN SystemStateSummary SSS ON SSSH.SystemStateSummaryId = SSS.Id
                     WHERE EXISTS(SELECT OrganisationId, [Code], COUNT(*) Cnt
                                         FROM SystemStateSummary SSS2
                                         WHERE SSS2.OrganisationId = SSS.OrganisationId AND SSS.[Code] = SSS2.[Code]
                                         GROUP BY OrganisationId, [Code]
                                         HAVING COUNT(*) > 1)

                     DELETE SSS
                     FROM SystemStateSummary SSS
                     WHERE EXISTS(SELECT OrganisationId, [Code], COUNT(*) Cnt
                                         FROM SystemStateSummary SSS2
                                         WHERE SSS2.OrganisationId = SSS.OrganisationId AND SSS.[Code] = SSS2.[Code]
                                         GROUP BY OrganisationId, [Code]
                                         HAVING COUNT(*) > 1)
                     
                     INSERT INTO [dbo].[SystemStateSummary] (
                                  [OrganisationId]
                                  , [Code]
                                  , [Message]
                                  , [SystemStateId]
                                  , [DateUpdated]
                                  , [AddedByUserId]
                                  )
                     SELECT DISTINCT O.Id AS [OrganisationId]
                                  , SC.[Code]
                                  , SC.[Message]
                                  , SC.[SystemStateId]
                                  , SC.[DateUpdated]
                                  , [dbo].[udfGetSystemUserId]() AS [AddedByUserId]
                     FROM Organisation O
                     INNER JOIN #SchedControl SC ON SC.OrganisationId = O.Id
                                                                     OR  SC.OrganisationId IS NULL
                     LEFT JOIN SystemStateSummary SSS ON SSS.OrganisationId = O.Id
                                                                                  AND SSS.[Code] = SC.[Code]
                     WHERE SSS.Id IS NULL;

                     UPDATE SSS
                     SET [Message] = SC.[Message]
                           , [SystemStateId] = SC.[SystemStateId]
                           , [DateUpdated] = SC.[DateUpdated]
                           , [AddedByUserId] = SC.[UpdatedByUserId]
                     FROM #SchedControl SC
                     INNER JOIN SystemStateSummary SSS ON SSS.OrganisationId = SC.OrganisationId
                                                                                  AND SSS.[Code] = SC.[Code];
       END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_15.01_CreateUpdateTriggerOnSchedulerControl.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO