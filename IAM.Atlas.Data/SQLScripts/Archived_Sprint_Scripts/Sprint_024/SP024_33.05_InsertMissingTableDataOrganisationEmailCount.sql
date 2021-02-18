/*
 * SCRIPT: Insert Missing Table Data OrganisationEmailCount
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_33.05_InsertMissingTableDataOrganisationEmailCount.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Insert Missing Table Data OrganisationEmailCount';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/* Record Emails Sent Against a Service */
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
			S.[OrganisationId]
			, DATEPART(yyyy, S.[DateSent]) as YearSent
			, DATEPART(mm, S.[DateSent]) as MonthSent
			, DATEPART(ww, S.[DateSent]) as WeekNumberSent
			, Count(*) AS NumberSent
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
			, SUM(CASE WHEN DATEPART(dw, S.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
		FROM [dbo].[EmailServiceEmailsSent] S
		LEFT JOIN [dbo].[OrganisationEmailCount] C ON ISNULL(C.[OrganisationId], -1) = ISNULL(S.[OrganisationId], -1)
													AND C.YearSent = DATEPART(yyyy, S.[DateSent])
													AND C.MonthSent = DATEPART(mm, S.[DateSent])
													AND C.WeekNumberSent =  DATEPART(ww, S.[DateSent])
		WHERE C.Id IS NULL
		GROUP BY S.[OrganisationId]
			, DATEPART(yyyy, S.[DateSent])
			, DATEPART(mm, S.[DateSent])
			, DATEPART(ww, S.[DateSent]);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
