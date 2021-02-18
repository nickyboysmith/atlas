
/*
	SCRIPT: Amend Insert trigger to the EmailServiceEmailsSent table
	Author: Robert Newnham
	Created: 17/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_34.02_CreateInsertTriggerToTableScheduleEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger to the EmailServiceEmailsSent table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_EmailServiceEmailsSent_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_EmailServiceEmailsSent_INSERT];
		END
	GO

	CREATE TRIGGER TRG_EmailServiceEmailsSent_INSERT ON EmailServiceEmailsSent FOR INSERT
	AS	
	BEGIN
		/* First Record Emails Sent Against a Service */
		
		INSERT INTO [dbo].[EmailServiceEmailCount] (
												EmailServiceId
												, YearSent
												, MonthSent
												, WeekNumberSent
												, NumberSent
												, NumberSentMonday
												, NumberSentTuesday
												, NumberSentWednesday
												, NumberSentThursday
												, NumberSentFriday
												, NumberSentSaturday
												, NumberSentSunday
												)
		SELECT 
			i.[EmailServiceId]
			, DATEPART(yyyy, i.[DateSent]) as YearSent
			, DATEPART(mm, i.[DateSent]) as MonthSent
			, DATEPART(ww, i.[DateSent]) as WeekNumberSent
			, Count(*) AS NumberSent
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
		FROM INSERTED i
		LEFT JOIN [dbo].[EmailServiceEmailCount] C ON ISNULL(C.EmailServiceId, -1) = ISNULL(i.[EmailServiceId], -1)
													AND C.YearSent = DATEPART(yyyy, i.[DateSent])
													AND C.MonthSent = DATEPART(mm, i.[DateSent])
													AND C.WeekNumberSent =  DATEPART(ww, i.[DateSent])
		WHERE C.Id IS NULL
		GROUP BY i.[EmailServiceId]
			, DATEPART(yyyy, i.[DateSent])
			, DATEPART(mm, i.[DateSent])
			, DATEPART(ww, i.[DateSent]);

		IF (@@ROWCOUNT <= 0)
		BEGIN
			/* No Rows Inserted Therefore need to Update*/
			UPDATE C
			SET C.NumberSent = C.NumberSent + S.NumberSent
			, C.NumberSentMonday = C.NumberSentMonday + S.NumberSentMonday
			, C.NumberSentTuesday = C.NumberSentTuesday + S.NumberSentTuesday
			, C.NumberSentWednesday = C.NumberSentWednesday + S.NumberSentWednesday
			, C.NumberSentThursday = C.NumberSentThursday + S.NumberSentThursday
			, C.NumberSentFriday = C.NumberSentFriday + S.NumberSentFriday
			, C.NumberSentSaturday = C.NumberSentSaturday + S.NumberSentSaturday
			, C.NumberSentSunday = C.NumberSentSunday + S.NumberSentSunday
			FROM [dbo].[EmailServiceEmailCount] C
			INNER JOIN (
						SELECT 
							i.[EmailServiceId]
							, DATEPART(yyyy, i.[DateSent]) as YearSent
							, DATEPART(mm, i.[DateSent]) as MonthSent
							, DATEPART(ww, i.[DateSent]) as WeekNumberSent
							, Count(*) AS NumberSent
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
						FROM INSERTED i
						GROUP BY i.[EmailServiceId]
							, DATEPART(yyyy, i.[DateSent])
							, DATEPART(mm, i.[DateSent])
							, DATEPART(ww, i.[DateSent])
						) S ON S.[EmailServiceId] = C.[EmailServiceId]
							AND S.YearSent = C.YearSent
							AND S.MonthSent = C.MonthSent
							AND S.WeekNumberSent = C.WeekNumberSent

		END
		
		/* First Record Emails Sent Against a Organisation */
		
		INSERT INTO [dbo].[OrganisationEmailCount] (
												OrganisationId
												, YearSent
												, MonthSent
												, WeekNumberSent
												, NumberSent
												, NumberSentMonday
												, NumberSentTuesday
												, NumberSentWednesday
												, NumberSentThursday
												, NumberSentFriday
												, NumberSentSaturday
												, NumberSentSunday
												)
		SELECT 
			i.[OrganisationId]
			, DATEPART(yyyy, i.[DateSent]) as YearSent
			, DATEPART(mm, i.[DateSent]) as MonthSent
			, DATEPART(ww, i.[DateSent]) as WeekNumberSent
			, Count(*) AS NumberSent
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
			, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
		FROM INSERTED i
		LEFT JOIN [dbo].[OrganisationEmailCount] C ON ISNULL(C.OrganisationId, -1) = ISNULL(i.[OrganisationId], -1)
													AND C.YearSent = DATEPART(yyyy, i.[DateSent])
													AND C.MonthSent = DATEPART(mm, i.[DateSent])
													AND C.WeekNumberSent =  DATEPART(ww, i.[DateSent])
		WHERE C.Id IS NULL
		GROUP BY i.[OrganisationId]
			, DATEPART(yyyy, i.[DateSent])
			, DATEPART(mm, i.[DateSent])
			, DATEPART(ww, i.[DateSent]);

		IF (@@ROWCOUNT <= 0)
		BEGIN
			/* No Rows Inserted Therefore need to Update*/
			UPDATE C
			SET C.NumberSent = C.NumberSent + S.NumberSent
			, C.NumberSentMonday = C.NumberSentMonday + S.NumberSentMonday
			, C.NumberSentTuesday = C.NumberSentTuesday + S.NumberSentTuesday
			, C.NumberSentWednesday = C.NumberSentWednesday + S.NumberSentWednesday
			, C.NumberSentThursday = C.NumberSentThursday + S.NumberSentThursday
			, C.NumberSentFriday = C.NumberSentFriday + S.NumberSentFriday
			, C.NumberSentSaturday = C.NumberSentSaturday + S.NumberSentSaturday
			, C.NumberSentSunday = C.NumberSentSunday + S.NumberSentSunday
			FROM [dbo].[OrganisationEmailCount] C
			INNER JOIN (
						SELECT 
							i.[OrganisationId]
							, DATEPART(yyyy, i.[DateSent]) as YearSent
							, DATEPART(mm, i.[DateSent]) as MonthSent
							, DATEPART(ww, i.[DateSent]) as WeekNumberSent
							, Count(*) AS NumberSent
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
							, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
						FROM INSERTED i
						GROUP BY i.[OrganisationId]
							, DATEPART(yyyy, i.[DateSent])
							, DATEPART(mm, i.[DateSent])
							, DATEPART(ww, i.[DateSent])
						) S ON S.[OrganisationId] = C.[OrganisationId]
							AND S.YearSent = C.YearSent
							AND S.MonthSent = C.MonthSent
							AND S.WeekNumberSent = C.WeekNumberSent

		END

		/* Check if the Maximum Emails for the day has been sent */
		DECLARE @EmailsTodaySoFar INT = 0;
		SELECT @EmailsTodaySoFar = Count(*)
		FROM [dbo].[EmailServiceEmailsSent]
		WHERE [DateSent] >= DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())) 
		AND [DateSent] < DATEADD(dd, 0, 1 + DATEDIFF(dd, 0, GETDATE()));

		IF (@EmailsTodaySoFar >= [dbo].[udfGetMaxNumberEmailsToProcessPerDay]())
		BEGIN			
			UPDATE SchedulerControl 
			SET [EmailScheduleDisabled] = 'True'
			, [DateUpdated] = GetDate()
			, [UpdatedByUserId] = [dbo].[udfGetSystemUserId]() 
			WHERE Id = 1;

			INSERT INTO [dbo].[Note] (Note, DateCreated, CreatedByUserId, NoteTypeId)
			VALUES (
				'Email Scheduler Disabled by Atlas as the Maximum Emails for the Day has been Reached.'
				, GetDate()
				, [dbo].[udfGetSystemUserId]()
				, (SELECT Id FROM [dbo].[NoteType] WHERE [Name] = 'General')
				);
			
			INSERT INTO [dbo].[SchedulerControlNote] (NoteId)
			VALUES(@@IDENTITY);

		END
	END
	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP024_34.02_CreateInsertTriggerToTableScheduleEmail.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO