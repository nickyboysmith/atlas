/*
	SCRIPT: Create a Dashboard Meter View for Courses
	Author: Robert Newnham
	Created: 08/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_16.01_CreateView_vwDashboardMeter_Email.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_Email';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_Email', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_Email;
	END		
	GO

	/*
		Create View vwDashboardMeter_Email
	*/
	CREATE VIEW vwDashboardMeter_Email AS	
		SELECT 
				O.[Id] As OrganisationId
				, O.[Name] AS OrganisationName
				, (CASE WHEN Email.EmailsSentToday IS NULL
						THEN 0
						ELSE Email.EmailsSentToday
						END) AS EmailsSentToday
				, (CASE WHEN Email.EmailsSentYesterday IS NULL
						THEN 0
						ELSE Email.EmailsSentYesterday
						END) AS EmailsSentYesterday
				, (CASE WHEN Email.EmailsSentThisMonth IS NULL
						THEN 0
						ELSE Email.EmailsSentThisMonth
						END) AS EmailsSentThisMonth
				, (CASE WHEN Email.EmailsSentLastMonth IS NULL
						THEN 0
						ELSE Email.EmailsSentLastMonth
						END) AS EmailsSentLastMonth
				, (CASE WHEN Email2.ScheduledCount IS NULL
						THEN 0
						ELSE Email2.ScheduledCount
						END) AS ScheduledEmails
		FROM [dbo].[Organisation] O
		LEFT JOIN (SELECT O2.[Id] 
						, SUM(CASE WHEN CAST(ESES.[DateSent] AS DATE) = CAST(Getdate() AS DATE)
								THEN 1 ELSE 0 END) AS EmailsSentToday
						, SUM(CASE WHEN CAST(ESES.[DateSent] AS DATE) = CAST(Getdate()-1 AS DATE)
								THEN 1 ELSE 0 END) AS EmailsSentYesterday
						, SUM(CASE WHEN ESES.[DateSent]
									BETWEEN DATEFROMPARTS(YEAR(GetDate()), MONTH(GetDate()), 1) --1st of This Month
									AND GetDate() --end of This Month (now DOH!)
								THEN 1 ELSE 0 END) AS EmailsSentThisMonth
						, SUM(CASE WHEN MONTH(GetDate()) > 1 
										AND ESES.[DateSent]
											BETWEEN DATEFROMPARTS(YEAR(GetDate()) ,MONTH(GetDate()) - 1, 1) --1st of Previous Month
											AND DATEADD(d,-1,DATEFROMPARTS(YEAR(GetDate()), MONTH(GetDate()), 1)) --end of Previous Month
									THEN 1
									WHEN MONTH(GetDate()) = 1 
										AND ESES.[DateSent]
											BETWEEN DATEFROMPARTS(YEAR(GetDate())-1 ,12, 1) --1st of Previous Month
											AND DATEADD(d,-1,DATEFROMPARTS(YEAR(GetDate()), MONTH(GetDate()), 1)) --end of Previous Month
									THEN 1
									ELSE 0 END) AS EmailsSentLastMonth
					FROM [dbo].[Organisation] O2
					INNER JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[OrganisationId] = O2.Id
					INNER JOIN [dbo].[EmailServiceEmailsSent] ESES ON ESES.[ScheduledEmailId] = OSE.[ScheduledEmailId]
					WHERE ESES.[DateSent] >= DATEFROMPARTS(YEAR(GetDate()) ,MONTH(GetDate()) - 1, 1) --1st of Previous Month
					GROUP BY O2.[Id]
					) Email ON Email.[Id] = O.[Id]
		LEFT JOIN (SELECT O2.[Id] 
					, COUNT(*) AS ScheduledCount 
					FROM [dbo].[Organisation] O2
					INNER JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[OrganisationId] = O2.Id
					LEFT JOIN [dbo].[EmailServiceEmailsSent] ESES ON ESES.[ScheduledEmailId] = OSE.[ScheduledEmailId]
					WHERE (ESES.Id IS NULL)
					GROUP BY O2.[Id]
					) Email2 ON Email2.[Id] = O.[Id]
		;

		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_16.01_CreateView_vwDashboardMeter_Email.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
