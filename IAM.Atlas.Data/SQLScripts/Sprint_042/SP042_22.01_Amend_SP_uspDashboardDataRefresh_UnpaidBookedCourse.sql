/*
	SCRIPT: Amend Stored procedure uspDashboardDataRefresh_UnpaidBookedCourse
	Author: Robert Newnham
	Amended: 27/08/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_22.01_Amend_SP_uspDashboardDataRefresh_UnpaidBookedCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored procedure uspDashboardDataRefresh_UnpaidBookedCourse';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_UnpaidBookedCourse', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_UnpaidBookedCourse;
END		
GO
	/*
		Amend uspDashboardDataRefresh_UnpaidBookedCourse
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_UnpaidBookedCourse] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_UnpaidBookedCourse'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;			
		/*****************************************************************************************************************************/			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_UnpaidBookedCourse TABLE (
																		[OrganisationId] [int]
																		, [OrganisationName] [varchar](320)
																		, [TotalNumberUnpaid] [int] NULL
																		, [TotalAmountUnpaid] [int] NULL
																		, [DateAndTimeRefreshed] [datetime]
																		);

			INSERT INTO @TempDashboardMeterData_UnpaidBookedCourse (
																	OrganisationId
																	, OrganisationName
																	, TotalNumberUnpaid
																	, TotalAmountUnpaid
																	, DateAndTimeRefreshed
																	)
			SELECT O2.[Id]									AS OrganisationId
				, O2.[Name]									AS OrganisationName
				, COUNT(*)									AS TotalNumberUnpaid
				, SUM(CASE WHEN CCP2.Id IS NULL 
							THEN CC2.[TotalPaymentDue] 
							ELSE 0 END)						AS TotalAmountUnpaid
				, GETDATE()									AS DateAndTimeRefreshed
			FROM [dbo].[Organisation] O2
			INNER JOIN [dbo].[Course] C2				ON C2.[OrganisationId] = O2.Id
			INNER JOIN [dbo].[CourseClient] CC2			ON CC2.[CourseId] = C2.Id
			INNER JOIN [dbo].[vwCourseDates_SubView] CD ON CD.Courseid = C2.Id
			LEFT JOIN [dbo].[CourseClientRemoved] CCR	ON CCR.CourseId = C2.Id
														AND CCR.ClientId = CC2.ClientId
														AND CCR.CourseClientId = CC2.Id
			LEFT JOIN [dbo].[CourseClientPayment] CCP2	ON CCP2.[CourseId] = C2.Id
														AND CCP2.[ClientId] = CC2.[ClientId]
			WHERE CCR.Id IS NULL AND CCP2.Id IS NULL
			AND CD.StartDate BETWEEN DATEADD(WEEK, -1, GETDATE()) AND DATEADD(WEEK, +3, GETDATE())
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
				, ISNULL(D.TotalNumberUnpaid,0)
				, ISNULL(D.TotalAmountUnpaid,0)
			FROM @TempDashboardMeterData_UnpaidBookedCourse D
			LEFT JOIN DashboardMeterData_UnpaidBookedCourse T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalNumberUnpaid = ISNULL(D.TotalNumberUnpaid,0)
				, T.TotalAmountUnpaid = ISNULL(D.TotalAmountUnpaid,0)
			FROM @TempDashboardMeterData_UnpaidBookedCourse D
			INNER JOIN DashboardMeterData_UnpaidBookedCourse T ON T.OrganisationId = D.OrganisationId
			;

			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_UnpaidBookedCourse T
			LEFT JOIN @TempDashboardMeterData_UnpaidBookedCourse D ON D.OrganisationId = T.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP042_22.01_Amend_SP_uspDashboardDataRefresh_UnpaidBookedCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
