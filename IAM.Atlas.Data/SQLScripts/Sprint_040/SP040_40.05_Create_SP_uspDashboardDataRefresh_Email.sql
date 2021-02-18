/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_Email
	Author: Robert Newnham
	Created: 17/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.05_Create_SP_uspDashboardDataRefresh_Email.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_Email';

/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_Email', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_Email;
END		
GO
	/*
		Create uspDashboardDataRefresh_Email
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_Email] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_Email'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 

			DECLARE @TempDashboardMeterData_Email TABLE (
															[OrganisationId] [int]
															, [OrganisationName] [varchar](320)
															, [EmailsSentToday] [int]
															, [EmailsSentYesterday] [int]
															, [EmailsSentThisMonth] [int]
															, [EmailsSentLastMonth] [int]
															, [ScheduledEmails] [int]
															, [DateAndTimeRefreshed] [datetime]
															);
			INSERT INTO @TempDashboardMeterData_Email(
														OrganisationId
														, OrganisationName
														, EmailsSentToday
														, EmailsSentYesterday
														, EmailsSentThisMonth
														, EmailsSentLastMonth
														, ScheduledEmails
														, DateAndTimeRefreshed
														)
			SELECT 
				O.[Id]												As OrganisationId
				, O.[Name]											AS OrganisationName
				, (CASE WHEN Email.EmailsSentToday IS NULL
						THEN 0
						ELSE Email.EmailsSentToday
						END)										AS EmailsSentToday
				, (CASE WHEN Email.EmailsSentYesterday IS NULL
						THEN 0
						ELSE Email.EmailsSentYesterday
						END)										AS EmailsSentYesterday
				, (CASE WHEN Email.EmailsSentThisMonth IS NULL
						THEN 0
						ELSE Email.EmailsSentThisMonth
						END)										AS EmailsSentThisMonth
				, (CASE WHEN Email.EmailsSentLastMonth IS NULL
						THEN 0
						ELSE Email.EmailsSentLastMonth
						END)										AS EmailsSentLastMonth
				, (CASE WHEN Email2.ScheduledCount IS NULL
						THEN 0
						ELSE Email2.ScheduledCount
						END)										AS ScheduledEmails
				, GETDATE()											AS DateAndTimeRefreshed
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
						WHERE ESES.[DateSent] >= 
									(CASE WHEN MONTH(GetDate()) = 1 
										THEN DATEFROMPARTS(
															(YEAR(GetDate()) -1)
															, 12
															, 1) --1st of Previous Month
										ELSE DATEFROMPARTS(
															YEAR(GetDate())
															, MONTH(GetDate()) - 1
															, 1) --1st of Previous Month
										END)
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

			INSERT INTO dbo.DashboardMeterData_Email(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, EmailsSentToday
				, EmailsSentYesterday
				, EmailsSentThisMonth
				, EmailsSentLastMonth
				, ScheduledEmails
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.EmailsSentToday
				, D.EmailsSentYesterday
				, D.EmailsSentThisMonth
				, D.EmailsSentLastMonth
				, D.ScheduledEmails
			FROM @TempDashboardMeterData_Email D
			LEFT JOIN DashboardMeterData_Email T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.EmailsSentToday = D.EmailsSentToday
				, T.EmailsSentYesterday = D.EmailsSentYesterday
				, T.EmailsSentThisMonth = D.EmailsSentThisMonth
				, T.EmailsSentLastMonth = D.EmailsSentLastMonth
				, T.ScheduledEmails = D.ScheduledEmails
			FROM @TempDashboardMeterData_Email D
			INNER JOIN DashboardMeterData_Email T ON T.OrganisationId = D.OrganisationId
			;
			
		END TRY  
		BEGIN CATCH  
			SELECT 
				@ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrorMessage = ERROR_MESSAGE()
				;

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrorMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH;   

		/*****************************************************************************************************************************/
	END
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.05_Create_SP_uspDashboardDataRefresh_Email.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
