/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_Payment
	Author: Robert Newnham
	Created: 17/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.07_Create_SP_uspDashboardDataRefresh_Payment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_Payment';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_Payment', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_Payment;
END		
GO
	/*
		Create uspDashboardDataRefresh_Payment
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_Payment] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_Payment'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_Payment TABLE (
															[OrganisationId] [int]
															, [OrganisationName] [varchar](320)
															, [NumberOfPaymentsTakenToday] [int]
															, [NumberOfPaymentsTakenYesterday] [int]
															, [NumberOfPaymentsTakenThisWeek] [int]
															, [NumberOfPaymentsTakenThisMonth] [int]
															, [NumberOfPaymentsTakenPreviousMonth] [int]
															, [NumberOfPaymentsTakenThisYear] [int]
															, [NumberOfPaymentsTakenPreviousYear] [int]
															, [NumberOfOnlinePaymentsTakenToday] [int]
															, [NumberOfOnlinePaymentsTakenYesterday] [int]
															, [NumberOfOnlinePaymentsTakenThisWeek] [int]
															, [NumberOfOnlinePaymentsTakenThisMonth] [int]
															, [NumberOfOnlinePaymentsTakenPreviousMonth] [int]
															, [NumberOfOnlinePaymentsTakenThisYear] [int]
															, [NumberOfOnlinePaymentsTakenPreviousYear] [int]
															, [NumberOfUnallocatedPaymentsTakenToday] [int]
															, [NumberOfUnallocatedPaymentsTakenYesterday] [int]
															, [NumberOfUnallocatedPaymentsTakenThisWeek] [int]
															, [NumberOfUnallocatedPaymentsTakenThisMonth] [int]
															, [NumberOfUnallocatedPaymentsTakenPreviousMonth] [int]
															, [NumberOfUnallocatedPaymentsTakenThisYear] [int]
															, [NumberOfUnallocatedPaymentsTakenPreviousYear] [int]
															, [NumberOfRefundedPaymentsTakenToday] [int]
															, [NumberOfRefundedPaymentsTakenYesterday] [int]
															, [NumberOfRefundedPaymentsTakenThisWeek] [int]
															, [NumberOfRefundedPaymentsTakenThisMonth] [int]
															, [NumberOfRefundedPaymentsTakenPreviousMonth] [int]
															, [NumberOfRefundedPaymentsTakenThisYear] [int]
															, [NumberOfRefundedPaymentsTakenPreviousYear] [int]
															, [PaymentSumTakenToday] [money]
															, [PaymentSumTakenYesterday] [money]
															, [PaymentSumTakenThisWeek] [money]
															, [PaymentSumTakenThisMonth] [money]
															, [PaymentSumTakenPreviousMonth] [money]
															, [PaymentSumTakenThisYear] [money]
															, [PaymentSumTakenPreviousYear] [money]
															, [DateAndTimeRefreshed] [datetime]
															);
			INSERT INTO @TempDashboardMeterData_Payment(
															OrganisationId
															, OrganisationName
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
															, DateAndTimeRefreshed
															)
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
			FROM vwPaymentsLinksDetail P
			INNER JOIN Organisation O ON P.OrganisationId = O.Id
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
			FROM @TempDashboardMeterData_Payment D
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
			FROM @TempDashboardMeterData_Payment D
			INNER JOIN DashboardMeterData_Payment T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_Payment T
			LEFT JOIN @TempDashboardMeterData_Payment D ON D.OrganisationId = T.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.07_Create_SP_uspDashboardDataRefresh_Payment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
