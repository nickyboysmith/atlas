/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_OnlineClientsSpecialRequirement
	Author: Robert Newnham
	Created: 17/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.06_Create_SP_uspDashboardDataRefresh_OnlineClientsSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_OnlineClientsSpecialRequirement';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_OnlineClientsSpecialRequirement', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_OnlineClientsSpecialRequirement;
END		
GO
	/*
		Create uspDashboardDataRefresh_OnlineClientsSpecialRequirement
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_OnlineClientsSpecialRequirement] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_OnlineClientsSpecialRequirement'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_OnlineClientsSpecialRequirement TABLE (
																					[OrganisationId] [int]
																					, [OrganisationName] [varchar](320)
																					, [ClientsWithRequirementsRegisteredOnlineToday] [int]
																					, [TotalUpcomingClientsWithRequirements] [int]
																					, [DateAndTimeRefreshed] [datetime]
																					);
			INSERT INTO @TempDashboardMeterData_OnlineClientsSpecialRequirement(
																				OrganisationId
																				, OrganisationName
																				, ClientsWithRequirementsRegisteredOnlineToday
																				, TotalUpcomingClientsWithRequirements
																				, DateAndTimeRefreshed
																				)
			SELECT  
				O.[Id]										As OrganisationId
				, O.[Name]									AS OrganisationName
				, SUM(CASE WHEN CAST(CL.[DateCreated] AS DATE) = CAST((Getdate()) AS DATE)
							THEN 1 ELSE 0 END)				AS ClientsWithRequirementsRegisteredOnlineToday
				, COUNT(CL.Id)								AS TotalUpcomingClientsWithRequirements
				, GETDATE()									AS DateAndTimeRefreshed
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
			FROM @TempDashboardMeterData_OnlineClientsSpecialRequirement D
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
			FROM @TempDashboardMeterData_OnlineClientsSpecialRequirement D
			INNER JOIN DashboardMeterData_OnlineClientsSpecialRequirement T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_OnlineClientsSpecialRequirement T
			LEFT JOIN @TempDashboardMeterData_OnlineClientsSpecialRequirement D ON D.OrganisationId = T.OrganisationId
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
	END
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.06_Create_SP_uspDashboardDataRefresh_OnlineClientsSpecialRequirement.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
