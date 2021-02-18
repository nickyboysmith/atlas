
/*
	SCRIPT: Amend Update trigger to the SchedulerControl table
	Author: Robert Newnham
	Created: 18/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_19.01_AmendInsertTriggerToTableSchedulerControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the SchedulerControl table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_SchedulerControl_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_SchedulerControl_UPDATE];
		END
	GO

	CREATE TRIGGER TRG_SchedulerControl_UPDATE ON SchedulerControl FOR UPDATE
	AS	
		DECLARE @EmailCode CHAR(4) = 'EM01'
				, @ReportCode CHAR(4) = 'RP01'
				, @ArchiveCode CHAR(4) = 'AR01'
				, @SMSCode CHAR(4) = 'SM01'
				, @ArchiveCode2 CHAR(4) = 'AR02' --Email
				, @ArchiveCode3 CHAR(4) = 'AR03' --SMS
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
						END)					AS [Message]
				, (CASE WHEN [EmailScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			UNION 
			SELECT @ReportCode AS Code
				, (CASE WHEN [ReportScheduleDisabled] = 'True' 
						THEN 'Report Scheduler Disabled'
						ELSE 'Report Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [ReportScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			UNION 
			SELECT @ArchiveCode AS Code
				, (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
						THEN 'Archive Scheduler Disabled'
						ELSE 'Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			UNION 
			SELECT @SMSCode AS Code
				, (CASE WHEN [SMSScheduleDisabled] = 'True' 
						THEN 'SMS Scheduler Disabled'
						ELSE 'SMS Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [SMSScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			UNION 
			SELECT @ArchiveCode2 AS Code
				, (CASE WHEN [EmailArchiveDisabled] = 'True' 
						THEN 'Email Archive Scheduler Disabled'
						ELSE 'Email Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [EmailArchiveDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			UNION 
			SELECT @ArchiveCode3 AS Code
				, (CASE WHEN [SMSArchiveDisabled] = 'True' 
						THEN 'SMS Archive Scheduler Disabled'
						ELSE 'SMS Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [SMSArchiveDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			) SchedControl;
			
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


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_19.01_AmendInsertTriggerToTableSchedulerControl.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO