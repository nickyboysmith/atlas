/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh
	Author: Robert Newnham
	Created: 05/05/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_14.04_Create_SP_uspDashboardDataRefresh.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh;
END		
GO
	/*
		Create uspDashboardDataRefresh
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_Client', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_Client;
			END

			SELECT 
				O.Id As OrganisationId
				, O.Name AS OrganisationName
				, COUNT(*) AS TotalClients
				, SUM(CASE WHEN C.[SelfRegistration] = 'True' 
							AND CAST(C.[DateCreated] AS DATE) = CAST(Getdate() AS DATE)
							THEN 1 ELSE 0 END) AS RegisteredOnlineToday
				, SUM(CASE WHEN CAST(C.[DateCreated] AS DATE) = CAST(Getdate() AS DATE)
							THEN 1 ELSE 0 END) AS RegisteredToday
				, SUM(CASE WHEN C.[SelfRegistration] = 'True' 
							AND CAST(C.[DateCreated] AS DATE) = CAST((Getdate() - 1) AS DATE)
							THEN 1 ELSE 0 END) AS RegisteredOnlineYesterday
				, SUM(CASE WHEN CAST(C.[DateCreated] AS DATE) = CAST((Getdate() - 1) AS DATE)
							THEN 1 ELSE 0 END) AS RegisteredYesterday
				, (CASE WHEN UBC.TotalNumberUnpaid IS NULL 
						THEN 0 ELSE UBC.TotalNumberUnpaid END) AS NumberOfUnpaidCourses
				, (CASE WHEN UBC.TotalAmountUnpaid IS NULL 
						THEN 0 ELSE UBC.TotalAmountUnpaid END) AS TotalAmountUnpaid	
				, ISNULL(OCSR.ClientsWithRequirementsRegisteredOnlineToday, 0) AS ClientsWithRequirementsRegisteredOnlineToday
				, ISNULL(OCSR.TotalUpcomingClientsWithRequirements, 0) AS TotalUpcomingClientsWithRequirements
				, GETDATE() AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_Client
			FROM [dbo].[Organisation] O
			INNER JOIN [dbo].[ClientOrganisation] CO ON CO.[OrganisationId] = O.Id
			INNER JOIN [dbo].[Client] C ON C.Id = CO.[ClientId]
			LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.Id
			LEFT JOIN vwDashboardMeter_OnlineClientsSpecialRequirement OCSR ON OCSR.OrganisationId = O.Id
			GROUP BY O.Id
					, O.Name
					, UBC.TotalNumberUnpaid
					, UBC.TotalAmountUnpaid
					, OCSR.ClientsWithRequirementsRegisteredOnlineToday
					, OCSR.TotalUpcomingClientsWithRequirements
			;

			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_Client(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalClients
				, RegisteredOnlineToday
				, RegisteredToday
				, RegisteredOnlineYesterday
				, RegisteredYesterday
				, NumberOfUnpaidCourses
				, TotalAmountUnpaid
				, ClientsWithRequirementsRegisteredOnlineToday
				, TotalUpcomingClientsWithRequirements
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.TotalClients
				, D.RegisteredOnlineToday
				, D.RegisteredToday
				, D.RegisteredOnlineYesterday
				, D.RegisteredYesterday
				, D.NumberOfUnpaidCourses
				, D.TotalAmountUnpaid
				, D.ClientsWithRequirementsRegisteredOnlineToday
				, D.TotalUpcomingClientsWithRequirements
			FROM #TempDashboardMeterData_Client D
			LEFT JOIN DashboardMeterData_Client T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalClients = D.TotalClients
				, T.RegisteredOnlineToday = D.RegisteredOnlineToday
				, T.RegisteredToday = D.RegisteredToday
				, T.RegisteredOnlineYesterday = D.RegisteredOnlineYesterday
				, T.RegisteredYesterday = D.RegisteredYesterday
				, T.NumberOfUnpaidCourses = D.NumberOfUnpaidCourses
				, T.TotalAmountUnpaid = D.TotalAmountUnpaid
				, T.ClientsWithRequirementsRegisteredOnlineToday = D.ClientsWithRequirementsRegisteredOnlineToday
				, T.TotalUpcomingClientsWithRequirements = D.TotalUpcomingClientsWithRequirements
			FROM #TempDashboardMeterData_Client D
			INNER JOIN DashboardMeterData_Client T ON T.OrganisationId = D.OrganisationId
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_Course', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_Course;
			END

			
			SELECT 
				O.[Id] As OrganisationId
				, O.[Name] AS OrganisationName
				, ISNULL(CourseAttendance.CoursesWithoutAttendance,0) AS CoursesWithoutAttendance
				, ISNULL(CourseAttendanceVerfication.CoursesWithoutAttendanceVerfication,0) AS CoursesWithoutAttendanceVerfication
				, ISNULL(UBC.TotalNumberUnpaid,0) AS NumberOfUnpaidCourses
				, ISNULL(UBC.TotalAmountUnpaid,0) AS TotalAmountUnpaid	
				, GETDATE() AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_Course
			FROM [dbo].[Organisation] O
			LEFT JOIN (SELECT O2.Id
							, COUNT(*) AS CoursesWithoutAttendance
						FROM [dbo].[Organisation] O2
						INNER JOIN [dbo].[Course] C ON C.[OrganisationId] = O2.[Id]
						INNER JOIN [dbo].[CourseDate] CD ON CD.CourseId = C.Id
						INNER JOIN [dbo].[CourseTrainer] CT ON CT.CourseId = C.Id
						WHERE C.AttendanceCheckRequired = 'True'
						AND C.AttendanceCheckVerified = 'False'
						AND CT.AttendanceCheckRequired = 'True'
						AND CD.DateEnd <= GetDate()
						AND NOT EXISTS (SELECT [Id] 
										FROM [dbo].[CourseDateClientAttendance] CDCA
										WHERE CDCA.[CourseId] = C.[Id]
										AND CDCA.TrainerId = CT.Id)
						GROUP BY O2.[Id]
						) CourseAttendance ON CourseAttendance.[Id] = O.[Id]
			LEFT JOIN (SELECT O3.Id
							, COUNT(DISTINCT C3.Id) AS CoursesWithoutAttendanceVerfication
						FROM [dbo].[Organisation] O3
						INNER JOIN [dbo].[Course] C3 ON C3.[OrganisationId] = O3.[Id]
						INNER JOIN [dbo].[CourseDate] CD3 ON CD3.CourseId = C3.Id
						INNER JOIN [dbo].[CourseTrainer] CT3 ON CT3.CourseId = C3.Id
						WHERE C3.AttendanceCheckRequired = 'True'
						AND C3.AttendanceCheckVerified = 'False'
						AND CD3.DateEnd <= GetDate()
						GROUP BY O3.[Id]
						) CourseAttendanceVerfication ON CourseAttendanceVerfication.[Id] = O.[Id]
			LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.[Id]
			;
			
			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_Course(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, CoursesWithoutAttendance
				, CoursesWithoutAttendanceVerfication
				, TotalAmountUnpaid
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.CoursesWithoutAttendance
				, D.CoursesWithoutAttendanceVerfication
				, D.TotalAmountUnpaid
			FROM #TempDashboardMeterData_Course D
			LEFT JOIN DashboardMeterData_Course T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.CoursesWithoutAttendance = D.CoursesWithoutAttendance
				, T.CoursesWithoutAttendanceVerfication = D.CoursesWithoutAttendanceVerfication
				, T.TotalAmountUnpaid = D.TotalAmountUnpaid
			FROM #TempDashboardMeterData_Course D
			INNER JOIN DashboardMeterData_Course T ON T.OrganisationId = D.OrganisationId
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_DocumentStat', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_DocumentStat;
			END

			SELECT 
				ISNULL(OrganisationId,0) AS OrganisationId
				, O.[Name] AS OrganisationName
				, NumberOfDocuments
				, TotalSize
				, NumberOfDocumentsThisMonth
				, TotalSizeOfDocumentsThisMonth
				, NumberOfDocumentsPreviousMonth
				, TotalSizeOfDocumentsPreviousMonth
				, NumberOfDocumentsThisYear
				, TotalSizeOfDocumentsThisYear
				, NumberOfDocumentsPreviousYear
				, TotalSizeOfDocumentsPreviousYear
				, NumberOfDocumentsPreviousTwoYears
				, TotalSizeOfDocumentsPreviousTwoYears
				, NumberOfDocumentsPreviousThreeYears
				, TotalSizeOfDocumentsPreviousThreeYears
				, GETDATE() AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_DocumentStat
			FROM dbo.Organisation O
			INNER JOIN dbo.DashboardMeter_DocumentSummary DS ON DS.OrganisationId = O.Id
			;
			
			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_DocumentStat(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalSize
				, NumberOfDocumentsThisMonth
				, TotalSizeOfDocumentsThisMonth
				, NumberOfDocumentsPreviousMonth
				, TotalSizeOfDocumentsPreviousMonth
				, NumberOfDocumentsThisYear
				, TotalSizeOfDocumentsThisYear
				, NumberOfDocumentsPreviousYear
				, TotalSizeOfDocumentsPreviousYear
				, NumberOfDocumentsPreviousTwoYears
				, TotalSizeOfDocumentsPreviousTwoYears
				, NumberOfDocumentsPreviousThreeYears
				, TotalSizeOfDocumentsPreviousThreeYears
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, ISNULL(D.TotalSize,0) AS TotalSize
				, D.NumberOfDocumentsThisMonth
				, D.TotalSizeOfDocumentsThisMonth
				, D.NumberOfDocumentsPreviousMonth
				, D.TotalSizeOfDocumentsPreviousMonth
				, D.NumberOfDocumentsThisYear
				, D.TotalSizeOfDocumentsThisYear
				, D.NumberOfDocumentsPreviousYear
				, D.TotalSizeOfDocumentsPreviousYear
				, D.NumberOfDocumentsPreviousTwoYears
				, ISNULL(D.TotalSizeOfDocumentsPreviousTwoYears,0) AS TotalSizeOfDocumentsPreviousTwoYears
				, D.NumberOfDocumentsPreviousThreeYears
				, D.TotalSizeOfDocumentsPreviousThreeYears
			FROM #TempDashboardMeterData_DocumentStat D
			LEFT JOIN DashboardMeterData_DocumentStat T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalSize = ISNULL(D.TotalSize,0)
				, T.NumberOfDocumentsThisMonth = D.NumberOfDocumentsThisMonth
				, T.TotalSizeOfDocumentsThisMonth = D.TotalSizeOfDocumentsThisMonth
				, T.NumberOfDocumentsPreviousMonth = D.NumberOfDocumentsPreviousMonth
				, T.TotalSizeOfDocumentsPreviousMonth = D.TotalSizeOfDocumentsPreviousMonth
				, T.NumberOfDocumentsThisYear = D.NumberOfDocumentsThisYear
				, T.TotalSizeOfDocumentsThisYear = D.TotalSizeOfDocumentsThisYear
				, T.NumberOfDocumentsPreviousYear = D.NumberOfDocumentsPreviousYear
				, T.TotalSizeOfDocumentsPreviousYear = D.TotalSizeOfDocumentsPreviousYear
				, T.NumberOfDocumentsPreviousTwoYears = D.NumberOfDocumentsPreviousTwoYears
				, T.TotalSizeOfDocumentsPreviousTwoYears = ISNULL(D.TotalSizeOfDocumentsPreviousTwoYears,0)
				, T.NumberOfDocumentsPreviousThreeYears = D.NumberOfDocumentsPreviousThreeYears
				, T.TotalSizeOfDocumentsPreviousThreeYears = D.TotalSizeOfDocumentsPreviousThreeYears
			FROM #TempDashboardMeterData_DocumentStat D
			INNER JOIN DashboardMeterData_DocumentStat T ON T.OrganisationId = D.OrganisationId
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_DORSOfferWithdrawn', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_DORSOfferWithdrawn;
			END

			SELECT ISNULL(OrganisationId,0)			AS OrganisationId
					, OrganisationName				AS OrganisationName
					, SUM(CASE WHEN CreatedToday = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedToday
					, SUM(CASE WHEN CreatedYesterday = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedYesterday
					, SUM(CASE WHEN CreatedThisWeek = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedThisWeek
					, SUM(CASE WHEN CreatedThisMonth = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedThisMonth
					, SUM(CASE WHEN CreatedPreviousMonth = 'True' THEN 1 ELSE 0 END)	AS TotalCreatedPreviousMonth
					, SUM(CASE WHEN CreatedTwoMonthsAgo = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedTwoMonthsAgo
				, GETDATE() AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_DORSOfferWithdrawn
			FROM vwDORSOfferWithdrawn
			GROUP BY ISNULL(OrganisationId,0), OrganisationName
			;
			
			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_DORSOfferWithdrawn(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalCreatedToday
				, TotalCreatedYesterday
				, TotalCreatedThisWeek
				, TotalCreatedThisMonth
				, TotalCreatedPreviousMonth
				, TotalCreatedTwoMonthsAgo
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.TotalCreatedToday
				, D.TotalCreatedYesterday
				, D.TotalCreatedThisWeek
				, D.TotalCreatedThisMonth
				, D.TotalCreatedPreviousMonth
				, D.TotalCreatedTwoMonthsAgo
			FROM #TempDashboardMeterData_DORSOfferWithdrawn D
			LEFT JOIN DashboardMeterData_DORSOfferWithdrawn T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;
			
			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalCreatedToday = D.TotalCreatedToday
				, T.TotalCreatedYesterday = D.TotalCreatedYesterday
				, T.TotalCreatedThisWeek = D.TotalCreatedThisWeek
				, T.TotalCreatedThisMonth = D.TotalCreatedThisMonth
				, T.TotalCreatedPreviousMonth = D.TotalCreatedPreviousMonth
				, T.TotalCreatedTwoMonthsAgo = D.TotalCreatedTwoMonthsAgo
			FROM #TempDashboardMeterData_DORSOfferWithdrawn D
			INNER JOIN DashboardMeterData_DORSOfferWithdrawn T ON T.OrganisationId = D.OrganisationId
			;

			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_DORSOfferWithdrawn T
			LEFT JOIN #TempDashboardMeterData_DORSOfferWithdrawn D ON D.OrganisationId = T.OrganisationId
			WHERE D.OrganisationId IS NULL --Not Found
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_Email', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_Email;
			END

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
				, GETDATE() AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_Email
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
			FROM #TempDashboardMeterData_Email D
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
			FROM #TempDashboardMeterData_Email D
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_OnlineClientsSpecialRequirement', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_OnlineClientsSpecialRequirement;
			END

			SELECT  
				O.[Id]			As OrganisationId
				, O.[Name]		AS OrganisationName
				, SUM(CASE WHEN CAST(CL.[DateCreated] AS DATE) = CAST((Getdate()) AS DATE)
							THEN 1 ELSE 0 END) AS ClientsWithRequirementsRegisteredOnlineToday
				, COUNT(CL.Id)			AS TotalUpcomingClientsWithRequirements
				, GETDATE()				AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_OnlineClientsSpecialRequirement
			FROM Client CL
			INNER JOIN [ClientOnlineBookingState] COBS				ON COBS.ClientId = CL.Id
			INNER JOIN Course CO									ON COBS.CourseId = CO.Id
			INNER JOIN dbo.Organisation O							ON O.Id = CO.OrganisationId
			INNER JOIN [ClientSpecialRequirement] CSR				ON CSR.ClientId = CL.Id
			INNER JOIN vwCourseDates_SubView CD						ON CO.Id = CD.CourseId
			WHERE CD.startdate > GETDATE()
			AND COBS.coursebooked = 'true' 
			AND COBS.FullPaymentRecieved = 'true'
			GROUP BY O.[Id], O.[Name];


			INSERT INTO dbo.DashboardMeterData_OnlineClientsSpecialRequirement(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, ClientsWithRequirementsRegisteredOnlineToday
				, TotalUpcomingClientsWithRequirements
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.ClientsWithRequirementsRegisteredOnlineToday
				, D.TotalUpcomingClientsWithRequirements
			FROM #TempDashboardMeterData_OnlineClientsSpecialRequirement D
			LEFT JOIN DashboardMeterData_OnlineClientsSpecialRequirement T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.ClientsWithRequirementsRegisteredOnlineToday = D.ClientsWithRequirementsRegisteredOnlineToday
				, T.TotalUpcomingClientsWithRequirements = D.TotalUpcomingClientsWithRequirements
			FROM #TempDashboardMeterData_OnlineClientsSpecialRequirement D
			INNER JOIN DashboardMeterData_OnlineClientsSpecialRequirement T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_OnlineClientsSpecialRequirement T
			LEFT JOIN #TempDashboardMeterData_OnlineClientsSpecialRequirement D ON D.OrganisationId = T.OrganisationId
			WHERE D.OrganisationId IS NULL --Not Found
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_Payment', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_Payment;
			END

			
			SELECT 
				O.Id																			AS OrganisationId
				, O.[Name]																		AS OrganisationName

				, SUM(CASE WHEN P.CreatedToday = 'True' THEN 1 ELSE 0 END)						AS NumberOfPaymentsTakenToday
				, SUM(CASE WHEN P.CreatedYesterday = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenYesterday
				, SUM(CASE WHEN P.CreatedThisWeek = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisWeek
				, SUM(CASE WHEN P.CreatedThisMonth = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisMonth
				, SUM(CASE WHEN P.CreatedPreviousMonth = 'True' THEN 1 ELSE 0 END)				AS NumberOfPaymentsTakenPreviousMonth
				, SUM(CASE WHEN P.CreatedThisYear = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisYear
				, SUM(CASE WHEN P.CreatedPreviousYear = 'True' THEN 1 ELSE 0 END)				AS NumberOfPaymentsTakenPreviousYear
			
				, SUM(CASE WHEN P.CreatedToday = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenToday
				, SUM(CASE WHEN P.CreatedYesterday = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenYesterday
				, SUM(CASE WHEN P.CreatedThisWeek = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisWeek
				, SUM(CASE WHEN P.CreatedThisMonth = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisMonth
				, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenPreviousMonth
				, SUM(CASE WHEN P.CreatedThisYear = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisYear
				, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
							AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenPreviousYear
						
				, SUM(CASE WHEN P.CreatedToday = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenToday
				, SUM(CASE WHEN P.CreatedYesterday = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenYesterday
				, SUM(CASE WHEN P.CreatedThisWeek = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisWeek
				, SUM(CASE WHEN P.CreatedThisMonth = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisMonth
				, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenPreviousMonth
				, SUM(CASE WHEN P.CreatedThisYear = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisYear
				, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
							AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenPreviousYear
						
				, SUM(CASE WHEN P.CreatedToday = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenToday
				, SUM(CASE WHEN P.CreatedYesterday = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenYesterday
				, SUM(CASE WHEN P.CreatedThisWeek = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisWeek
				, SUM(CASE WHEN P.CreatedThisMonth = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisMonth
				, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenPreviousMonth
				, SUM(CASE WHEN P.CreatedThisYear = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisYear
				, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
							AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenPreviousYear

				, SUM(CASE WHEN P.CreatedToday = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenToday
				, SUM(CASE WHEN P.CreatedYesterday = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenYesterday
				, SUM(CASE WHEN P.CreatedThisWeek = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenThisWeek
				, SUM(CASE WHEN P.CreatedThisMonth = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenThisMonth
				, SUM(CASE WHEN P.CreatedPreviousMonth = 'True' THEN P.PaymentAmount ELSE 0 END)	AS PaymentSumTakenPreviousMonth
				, SUM(CASE WHEN P.CreatedThisYear = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenThisYear
				, SUM(CASE WHEN P.CreatedPreviousYear = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenPreviousYear
				, GETDATE()																			AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_Payment
			FROM Organisation O
			LEFT JOIN vwPaymentsLinksDetail P ON P.OrganisationId = O.Id
			GROUP BY O.Id, O.[Name]
			;


			INSERT INTO dbo.DashboardMeterData_Payment(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, NumberOfPaymentsTakenToday
				, NumberOfPaymentsTakenYesterday
				, NumberOfPaymentsTakenThisWeek
				, NumberOfPaymentsTakenThisMonth
				, NumberOfPaymentsTakenPreviousMonth
				, NumberOfPaymentsTakenThisYear
				, NumberOfPaymentsTakenPreviousYear
				, NumberOfOnlinePaymentsTakenToday
				, NumberOfOnlinePaymentsTakenYesterday
				, NumberOfOnlinePaymentsTakenThisWeek
				, NumberOfOnlinePaymentsTakenThisMonth
				, NumberOfOnlinePaymentsTakenPreviousMonth
				, NumberOfOnlinePaymentsTakenThisYear
				, NumberOfOnlinePaymentsTakenPreviousYear
				, NumberOfUnallocatedPaymentsTakenToday
				, NumberOfUnallocatedPaymentsTakenYesterday
				, NumberOfUnallocatedPaymentsTakenThisWeek
				, NumberOfUnallocatedPaymentsTakenThisMonth
				, NumberOfUnallocatedPaymentsTakenPreviousMonth
				, NumberOfUnallocatedPaymentsTakenThisYear
				, NumberOfUnallocatedPaymentsTakenPreviousYear
				, NumberOfRefundedPaymentsTakenToday
				, NumberOfRefundedPaymentsTakenYesterday
				, NumberOfRefundedPaymentsTakenThisWeek
				, NumberOfRefundedPaymentsTakenThisMonth
				, NumberOfRefundedPaymentsTakenPreviousMonth
				, NumberOfRefundedPaymentsTakenThisYear
				, NumberOfRefundedPaymentsTakenPreviousYear
				, PaymentSumTakenToday
				, PaymentSumTakenYesterday
				, PaymentSumTakenThisWeek
				, PaymentSumTakenThisMonth
				, PaymentSumTakenPreviousMonth
				, PaymentSumTakenThisYear
				, PaymentSumTakenPreviousYear
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.NumberOfPaymentsTakenToday
				, D.NumberOfPaymentsTakenYesterday
				, D.NumberOfPaymentsTakenThisWeek
				, D.NumberOfPaymentsTakenThisMonth
				, D.NumberOfPaymentsTakenPreviousMonth
				, D.NumberOfPaymentsTakenThisYear
				, D.NumberOfPaymentsTakenPreviousYear
				, D.NumberOfOnlinePaymentsTakenToday
				, D.NumberOfOnlinePaymentsTakenYesterday
				, D.NumberOfOnlinePaymentsTakenThisWeek
				, D.NumberOfOnlinePaymentsTakenThisMonth
				, D.NumberOfOnlinePaymentsTakenPreviousMonth
				, D.NumberOfOnlinePaymentsTakenThisYear
				, D.NumberOfOnlinePaymentsTakenPreviousYear
				, D.NumberOfUnallocatedPaymentsTakenToday
				, D.NumberOfUnallocatedPaymentsTakenYesterday
				, D.NumberOfUnallocatedPaymentsTakenThisWeek
				, D.NumberOfUnallocatedPaymentsTakenThisMonth
				, D.NumberOfUnallocatedPaymentsTakenPreviousMonth
				, D.NumberOfUnallocatedPaymentsTakenThisYear
				, D.NumberOfUnallocatedPaymentsTakenPreviousYear
				, D.NumberOfRefundedPaymentsTakenToday
				, D.NumberOfRefundedPaymentsTakenYesterday
				, D.NumberOfRefundedPaymentsTakenThisWeek
				, D.NumberOfRefundedPaymentsTakenThisMonth
				, D.NumberOfRefundedPaymentsTakenPreviousMonth
				, D.NumberOfRefundedPaymentsTakenThisYear
				, D.NumberOfRefundedPaymentsTakenPreviousYear
				, D.PaymentSumTakenToday
				, D.PaymentSumTakenYesterday
				, D.PaymentSumTakenThisWeek
				, D.PaymentSumTakenThisMonth
				, D.PaymentSumTakenPreviousMonth
				, D.PaymentSumTakenThisYear
				, D.PaymentSumTakenPreviousYear
			FROM #TempDashboardMeterData_Payment D
			LEFT JOIN DashboardMeterData_Payment T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.NumberOfPaymentsTakenToday = D.NumberOfPaymentsTakenToday
				, T.NumberOfPaymentsTakenYesterday = D.NumberOfPaymentsTakenYesterday
				, T.NumberOfPaymentsTakenThisWeek = D.NumberOfPaymentsTakenThisWeek
				, T.NumberOfPaymentsTakenThisMonth = D.NumberOfPaymentsTakenThisMonth
				, T.NumberOfPaymentsTakenPreviousMonth = D.NumberOfPaymentsTakenPreviousMonth
				, T.NumberOfPaymentsTakenThisYear = D.NumberOfPaymentsTakenThisYear
				, T.NumberOfPaymentsTakenPreviousYear = D.NumberOfPaymentsTakenPreviousYear
				, T.NumberOfOnlinePaymentsTakenToday = D.NumberOfOnlinePaymentsTakenToday
				, T.NumberOfOnlinePaymentsTakenYesterday = D.NumberOfOnlinePaymentsTakenYesterday
				, T.NumberOfOnlinePaymentsTakenThisWeek = D.NumberOfOnlinePaymentsTakenThisWeek
				, T.NumberOfOnlinePaymentsTakenThisMonth = D.NumberOfOnlinePaymentsTakenThisMonth
				, T.NumberOfOnlinePaymentsTakenPreviousMonth = D.NumberOfOnlinePaymentsTakenPreviousMonth
				, T.NumberOfOnlinePaymentsTakenThisYear = D.NumberOfOnlinePaymentsTakenThisYear
				, T.NumberOfOnlinePaymentsTakenPreviousYear = D.NumberOfOnlinePaymentsTakenPreviousYear
				, T.NumberOfUnallocatedPaymentsTakenToday = D.NumberOfUnallocatedPaymentsTakenToday
				, T.NumberOfUnallocatedPaymentsTakenYesterday = D.NumberOfUnallocatedPaymentsTakenYesterday
				, T.NumberOfUnallocatedPaymentsTakenThisWeek = D.NumberOfUnallocatedPaymentsTakenThisWeek
				, T.NumberOfUnallocatedPaymentsTakenThisMonth = D.NumberOfUnallocatedPaymentsTakenThisMonth
				, T.NumberOfUnallocatedPaymentsTakenPreviousMonth = D.NumberOfUnallocatedPaymentsTakenPreviousMonth
				, T.NumberOfUnallocatedPaymentsTakenThisYear = D.NumberOfUnallocatedPaymentsTakenThisYear
				, T.NumberOfUnallocatedPaymentsTakenPreviousYear = D.NumberOfUnallocatedPaymentsTakenPreviousYear
				, T.NumberOfRefundedPaymentsTakenToday = D.NumberOfRefundedPaymentsTakenToday
				, T.NumberOfRefundedPaymentsTakenYesterday = D.NumberOfRefundedPaymentsTakenYesterday
				, T.NumberOfRefundedPaymentsTakenThisWeek = D.NumberOfRefundedPaymentsTakenThisWeek
				, T.NumberOfRefundedPaymentsTakenThisMonth = D.NumberOfRefundedPaymentsTakenThisMonth
				, T.NumberOfRefundedPaymentsTakenPreviousMonth = D.NumberOfRefundedPaymentsTakenPreviousMonth
				, T.NumberOfRefundedPaymentsTakenThisYear = D.NumberOfRefundedPaymentsTakenThisYear
				, T.NumberOfRefundedPaymentsTakenPreviousYear = D.NumberOfRefundedPaymentsTakenPreviousYear
				, T.PaymentSumTakenToday = D.PaymentSumTakenToday
				, T.PaymentSumTakenYesterday = D.PaymentSumTakenYesterday
				, T.PaymentSumTakenThisWeek = D.PaymentSumTakenThisWeek
				, T.PaymentSumTakenThisMonth = D.PaymentSumTakenThisMonth
				, T.PaymentSumTakenPreviousMonth = D.PaymentSumTakenPreviousMonth
				, T.PaymentSumTakenThisYear = D.PaymentSumTakenThisYear
				, T.PaymentSumTakenPreviousYear = D.PaymentSumTakenPreviousYear
			FROM #TempDashboardMeterData_Payment D
			INNER JOIN DashboardMeterData_Payment T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_Payment T
			LEFT JOIN #TempDashboardMeterData_Payment D ON D.OrganisationId = T.OrganisationId
			WHERE D.OrganisationId IS NULL --Not Found
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
			
		BEGIN TRY 

			IF OBJECT_ID('tempdb..#TempDashboardMeterData_UnpaidBookedCourse', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempDashboardMeterData_UnpaidBookedCourse;
			END

			SELECT O2.[Id]									AS OrganisationId
				, O2.[Name]									AS OrganisationName
				, COUNT(*)									AS TotalNumberUnpaid
				, SUM(CASE WHEN CCP2.Id IS NULL 
							THEN CC2.[TotalPaymentDue] 
							ELSE 0 END)						AS TotalAmountUnpaid
				, GETDATE()									AS DateAndTimeRefreshed
			INTO #TempDashboardMeterData_UnpaidBookedCourse
			FROM [dbo].[Organisation] O2
			INNER JOIN [dbo].[Course] C2				ON C2.[OrganisationId] = O2.Id
			INNER JOIN [dbo].[CourseClient] CC2			ON CC2.[CourseId] = C2.Id
			INNER JOIN [dbo].[vwCourseDates_SubView] CD ON CD.Courseid = C2.Id
			LEFT JOIN [dbo].[CourseClientPayment] CCP2	ON CCP2.[CourseId] = C2.Id
														AND CCP2.[ClientId] = CC2.[ClientId]
			WHERE CCP2.Id IS NULL
			GROUP BY O2.[Id], O2.[Name]
			;


			INSERT INTO dbo.DashboardMeterData_UnpaidBookedCourse(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalNumberUnpaid
				, TotalAmountUnpaid
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.TotalNumberUnpaid
				, D.TotalAmountUnpaid
			FROM #TempDashboardMeterData_UnpaidBookedCourse D
			LEFT JOIN DashboardMeterData_UnpaidBookedCourse T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalNumberUnpaid = D.TotalNumberUnpaid
				, T.TotalAmountUnpaid = D.TotalAmountUnpaid
			FROM #TempDashboardMeterData_UnpaidBookedCourse D
			INNER JOIN DashboardMeterData_UnpaidBookedCourse T ON T.OrganisationId = D.OrganisationId
			;

			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_UnpaidBookedCourse T
			LEFT JOIN #TempDashboardMeterData_UnpaidBookedCourse D ON D.OrganisationId = T.OrganisationId
			WHERE D.OrganisationId IS NULL --Not Found
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
		END CATCH
	
		/*****************************************************************************************************************************/
	END
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP037_14.04_Create_SP_uspDashboardDataRefresh.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
