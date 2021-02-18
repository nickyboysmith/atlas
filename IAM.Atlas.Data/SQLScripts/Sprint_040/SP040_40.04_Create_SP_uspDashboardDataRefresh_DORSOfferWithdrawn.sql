/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_DORSOfferWithdrawn
	Author: Robert Newnham
	Created: 17/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.04_Create_SP_uspDashboardDataRefresh_DORSOfferWithdrawn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_DORSOfferWithdrawn';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_DORSOfferWithdrawn', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_DORSOfferWithdrawn;
END		
GO
	/*
		Create uspDashboardDataRefresh_DORSOfferWithdrawn
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_DORSOfferWithdrawn] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_DORSOfferWithdrawn'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_DORSOfferWithdrawn TABLE (
																		[OrganisationId] [int]
																		, [OrganisationName] [varchar](320)
																		, [TotalCreatedToday] [int]
																		, [TotalCreatedYesterday] [int]
																		, [TotalCreatedThisWeek] [int]
																		, [TotalCreatedThisMonth] [int]
																		, [TotalCreatedPreviousMonth] [int]
																		, [TotalCreatedTwoMonthsAgo] [int]
																		, [DateAndTimeRefreshed] [datetime]
																		);

			INSERT INTO @TempDashboardMeterData_DORSOfferWithdrawn(
																	OrganisationId
																	, OrganisationName
																	, TotalCreatedToday
																	, TotalCreatedYesterday
																	, TotalCreatedThisWeek
																	, TotalCreatedThisMonth
																	, TotalCreatedPreviousMonth
																	, TotalCreatedTwoMonthsAgo
																	, DateAndTimeRefreshed
																	)
			SELECT ISNULL(OrganisationId,0)			AS OrganisationId
					, OrganisationName				AS OrganisationName
					, SUM(CASE WHEN CreatedToday = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedToday
					, SUM(CASE WHEN CreatedYesterday = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedYesterday
					, SUM(CASE WHEN CreatedThisWeek = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedThisWeek
					, SUM(CASE WHEN CreatedThisMonth = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedThisMonth
					, SUM(CASE WHEN CreatedPreviousMonth = 'True' THEN 1 ELSE 0 END)	AS TotalCreatedPreviousMonth
					, SUM(CASE WHEN CreatedTwoMonthsAgo = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedTwoMonthsAgo
					, GETDATE() AS DateAndTimeRefreshed
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
			FROM @TempDashboardMeterData_DORSOfferWithdrawn D
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
			FROM @TempDashboardMeterData_DORSOfferWithdrawn D
			INNER JOIN DashboardMeterData_DORSOfferWithdrawn T ON T.OrganisationId = D.OrganisationId
			;

			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_DORSOfferWithdrawn T
			LEFT JOIN @TempDashboardMeterData_DORSOfferWithdrawn D ON D.OrganisationId = T.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.04_Create_SP_uspDashboardDataRefresh_DORSOfferWithdrawn.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
