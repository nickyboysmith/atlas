/*
	SCRIPT: Alter Stored procedure uspDashboardDataRefresh
	Author: Robert Newnham
	Created: 24/09/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP044_06.01_Alter_SP_uspDashboardDataRefresh_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Stored procedure uspDashboardDataRefresh_Client';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_Client', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_Client;
END		
GO
	/*
		Create uspDashboardDataRefresh_Client
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_Client] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_Client'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 

			DECLARE @TempDashboardMeterData_Client TABLE (
														[OrganisationId] [int]
														, [OrganisationName] [varchar](320)
														, [TotalClients] [int]
														, [RegisteredOnlineToday] [int]
														, [RegisteredToday] [int]
														, [RegisteredOnlineYesterday] [int]
														, [RegisteredYesterday] [int]
														, [NumberOfUnpaidCourses] [int]
														, [TotalAmountUnpaid] [money]
														, [ClientsWithRequirementsRegisteredOnlineToday] [int]
														, [TotalUpcomingClientsWithRequirements] [int]
														, [UnableToUpdateInDORS] [int]
														, [AttendanceNotUploadedToDORS] [int]
														, [ClientsWithMissingReferringAuthorityCreatedThisWeek] [int]
														, [ClientsWithMissingReferringAuthorityCreatedThisMonth] [int]
														, [ClientsWithMissingReferringAuthorityCreatedLastMonth] [int]
														, [DateAndTimeRefreshed] [datetime]
														);

			INSERT INTO @TempDashboardMeterData_Client(
														OrganisationId
														, OrganisationName
														, TotalClients
														, RegisteredOnlineToday
														, RegisteredToday
														, RegisteredOnlineYesterday
														, RegisteredYesterday
														, NumberOfUnpaidCourses
														, TotalAmountUnpaid
														, ClientsWithRequirementsRegisteredOnlineToday
														, TotalUpcomingClientsWithRequirements
														, UnableToUpdateInDORS
														, AttendanceNotUploadedToDORS
														, ClientsWithMissingReferringAuthorityCreatedThisWeek
														, ClientsWithMissingReferringAuthorityCreatedThisMonth
														, ClientsWithMissingReferringAuthorityCreatedLastMonth
														, DateAndTimeRefreshed														
														)
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
				, ISNULL(UTUID.TotalClientsUnableToUpdateInDORS, 0) AS TotalClientsUnableToUpdateInDORS
				, ISNULL(ANUTD.TotalAttendanceNotUploadedToDORS, 0) AS TotalAttendanceNotUploadedToDORS
				, CWMDDS.TotalCreatedThisWeek AS ClientsWithMissingReferringAuthorityCreatedThisWeek
				, CWMDDS.TotalCreatedThisMonth AS ClientsWithMissingReferringAuthorityCreatedThisMonth
				, CWMDDS.TotalCreatedLastMonth AS ClientsWithMissingReferringAuthorityCreatedLastMonth
				, GETDATE() AS DateAndTimeRefreshed
			FROM [dbo].[Organisation] O
			INNER JOIN [dbo].[ClientOrganisation] CO ON CO.[OrganisationId] = O.Id
			INNER JOIN [dbo].[Client] C ON C.Id = CO.[ClientId]
			INNER JOIN vwClientsWithMissingDORSDataSummary CWMDDS ON CWMDDS.OrganisationId = O.Id
			LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.Id
			LEFT JOIN vwDashboardMeter_OnlineClientsSpecialRequirement OCSR ON OCSR.OrganisationId = O.Id
			LEFT JOIN vwDashboardMeter_UnableToUpdateInDORS UTUID ON UTUID.OrganisationId = O.Id
			LEFT JOIN vwDashboardMeter_AttendanceNotUploadedToDORS ANUTD ON ANUTD.OrganisationId = O.Id
			GROUP BY O.Id
					, O.Name
					, UBC.TotalNumberUnpaid
					, UBC.TotalAmountUnpaid
					, OCSR.ClientsWithRequirementsRegisteredOnlineToday
					, OCSR.TotalUpcomingClientsWithRequirements
					, UTUID.TotalClientsUnableToUpdateInDORS
					, ANUTD.TotalAttendanceNotUploadedToDORS
					, CWMDDS.TotalCreatedThisWeek
					, CWMDDS.TotalCreatedThisMonth
					, CWMDDS.TotalCreatedLastMonth
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
				, UnableToUpdateInDORS
				, AttendanceNotUploadedToDORS
				, ClientsWithMissingReferringAuthorityCreatedThisWeek
				, ClientsWithMissingReferringAuthorityCreatedThisMonth
				, ClientsWithMissingReferringAuthorityCreatedLastMonth
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
				, D.UnableToUpdateInDORS
				, D.AttendanceNotUploadedToDORS
				, D.ClientsWithMissingReferringAuthorityCreatedThisWeek
				, D.ClientsWithMissingReferringAuthorityCreatedThisMonth
				, D.ClientsWithMissingReferringAuthorityCreatedLastMonth
			FROM @TempDashboardMeterData_Client D
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
				, T.UnableToUpdateInDORS = D.UnableToUpdateInDORS
				, T.AttendanceNotUploadedToDORS = D.AttendanceNotUploadedToDORS
				, T.ClientsWithMissingReferringAuthorityCreatedThisWeek = D.ClientsWithMissingReferringAuthorityCreatedThisWeek
				, T.ClientsWithMissingReferringAuthorityCreatedThisMonth = D.ClientsWithMissingReferringAuthorityCreatedThisMonth
				, T.ClientsWithMissingReferringAuthorityCreatedLastMonth = D.ClientsWithMissingReferringAuthorityCreatedLastMonth
			FROM @TempDashboardMeterData_Client D
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
		END CATCH
	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP044_06.01_Alter_SP_uspDashboardDataRefresh_Client.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
