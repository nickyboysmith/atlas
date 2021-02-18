
		-- Dashboard Meter Data - Payments Summary
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwDashboardMeter_Payments', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwDashboardMeter_Payments;
		END		
		GO
		/*
			Create vwDashboardMeter_Payments
		*/
		CREATE VIEW vwDashboardMeter_Payments
		AS
			SELECT
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, ISNULL(NumberOfPaymentsTakenToday,0) AS NumberOfPaymentsTakenToday
				, ISNULL(NumberOfPaymentsTakenYesterday,0) AS NumberOfPaymentsTakenYesterday
				, ISNULL(NumberOfPaymentsTakenThisWeek,0) AS NumberOfPaymentsTakenThisWeek
				, ISNULL(NumberOfPaymentsTakenThisMonth,0) AS NumberOfPaymentsTakenThisMonth
				, ISNULL(NumberOfPaymentsTakenPreviousMonth,0) AS NumberOfPaymentsTakenPreviousMonth
				, ISNULL(NumberOfPaymentsTakenThisYear,0) AS NumberOfPaymentsTakenThisYear
				, ISNULL(NumberOfPaymentsTakenPreviousYear,0) AS NumberOfPaymentsTakenPreviousYear
				, ISNULL(NumberOfOnlinePaymentsTakenToday,0) AS NumberOfOnlinePaymentsTakenToday
				, ISNULL(NumberOfOnlinePaymentsTakenYesterday,0) AS NumberOfOnlinePaymentsTakenYesterday
				, ISNULL(NumberOfOnlinePaymentsTakenThisWeek,0) AS NumberOfOnlinePaymentsTakenThisWeek
				, ISNULL(NumberOfOnlinePaymentsTakenThisMonth,0) AS NumberOfOnlinePaymentsTakenThisMonth
				, ISNULL(NumberOfOnlinePaymentsTakenPreviousMonth,0) AS NumberOfOnlinePaymentsTakenPreviousMonth
				, ISNULL(NumberOfOnlinePaymentsTakenThisYear,0) AS NumberOfOnlinePaymentsTakenThisYear
				, ISNULL(NumberOfOnlinePaymentsTakenPreviousYear,0) AS NumberOfOnlinePaymentsTakenPreviousYear
				, ISNULL(NumberOfPhonePaymentsTakenToday,0) AS NumberOfPhonePaymentsTakenToday
				, ISNULL(NumberOfPhonePaymentsTakenYesterday,0) AS NumberOfPhonePaymentsTakenYesterday
				, ISNULL(NumberOfPhonePaymentsTakenThisWeek,0) AS NumberOfPhonePaymentsTakenThisWeek
				, ISNULL(NumberOfPhonePaymentsTakenThisMonth,0) AS NumberOfPhonePaymentsTakenThisMonth
				, ISNULL(NumberOfPhonePaymentsTakenPreviousMonth,0) AS NumberOfPhonePaymentsTakenPreviousMonth
				, ISNULL(NumberOfPhonePaymentsTakenThisYear,0) AS NumberOfPhonePaymentsTakenThisYear
				, ISNULL(NumberOfPhonePaymentsTakenPreviousYear,0) AS NumberOfPhonePaymentsTakenPreviousYear
				, ISNULL(NumberOfUnallocatedPaymentsTakenToday,0) AS NumberOfUnallocatedPaymentsTakenToday
				, ISNULL(NumberOfUnallocatedPaymentsTakenYesterday,0) AS NumberOfUnallocatedPaymentsTakenYesterday
				, ISNULL(NumberOfUnallocatedPaymentsTakenThisWeek,0) AS NumberOfUnallocatedPaymentsTakenThisWeek
				, ISNULL(NumberOfUnallocatedPaymentsTakenThisMonth,0) AS NumberOfUnallocatedPaymentsTakenThisMonth
				, ISNULL(NumberOfUnallocatedPaymentsTakenPreviousMonth,0) AS NumberOfUnallocatedPaymentsTakenPreviousMonth
				, ISNULL(NumberOfUnallocatedPaymentsTakenThisYear,0) AS NumberOfUnallocatedPaymentsTakenThisYear
				, ISNULL(NumberOfUnallocatedPaymentsTakenPreviousYear,0) AS NumberOfUnallocatedPaymentsTakenPreviousYear
				, ISNULL(NumberOfRefundedPaymentsTakenToday,0) AS NumberOfRefundedPaymentsTakenToday
				, ISNULL(NumberOfRefundedPaymentsTakenYesterday,0) AS NumberOfRefundedPaymentsTakenYesterday
				, ISNULL(NumberOfRefundedPaymentsTakenThisWeek,0) AS NumberOfRefundedPaymentsTakenThisWeek
				, ISNULL(NumberOfRefundedPaymentsTakenThisMonth,0) AS NumberOfRefundedPaymentsTakenThisMonth
				, ISNULL(NumberOfRefundedPaymentsTakenPreviousMonth,0) AS NumberOfRefundedPaymentsTakenPreviousMonth
				, ISNULL(NumberOfRefundedPaymentsTakenThisYear,0) AS NumberOfRefundedPaymentsTakenThisYear
				, ISNULL(NumberOfRefundedPaymentsTakenPreviousYear,0) AS NumberOfRefundedPaymentsTakenPreviousYear
				, ISNULL(PaymentSumTakenToday,0) AS PaymentSumTakenToday
				, ISNULL(PaymentSumTakenYesterday,0) AS PaymentSumTakenYesterday
				, ISNULL(PaymentSumTakenThisWeek,0) AS PaymentSumTakenThisWeek
				, ISNULL(PaymentSumTakenThisMonth,0) AS PaymentSumTakenThisMonth
				, ISNULL(PaymentSumTakenPreviousMonth,0) AS PaymentSumTakenPreviousMonth
				, ISNULL(PaymentSumTakenThisYear,0) AS PaymentSumTakenThisYear
				, ISNULL(PaymentSumTakenPreviousYear,0) AS PaymentSumTakenPreviousYear
			FROM [dbo].[DashboardMeterData_Payment] P
			;

			--SELECT 
			--	--P.OrganisationId				AS OrganisationId
			--	--, P.OrganisationName			AS OrganisationName
			--	O.Id																			AS OrganisationId
			--	, O.[Name]																		AS OrganisationName

			--	, SUM(CASE WHEN P.CreatedToday = 'True' THEN 1 ELSE 0 END)						AS NumberOfPaymentsTakenToday
			--	, SUM(CASE WHEN P.CreatedYesterday = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenYesterday
			--	, SUM(CASE WHEN P.CreatedThisWeek = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisWeek
			--	, SUM(CASE WHEN P.CreatedThisMonth = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisMonth
			--	, SUM(CASE WHEN P.CreatedPreviousMonth = 'True' THEN 1 ELSE 0 END)				AS NumberOfPaymentsTakenPreviousMonth
			--	, SUM(CASE WHEN P.CreatedThisYear = 'True' THEN 1 ELSE 0 END)					AS NumberOfPaymentsTakenThisYear
			--	, SUM(CASE WHEN P.CreatedPreviousYear = 'True' THEN 1 ELSE 0 END)				AS NumberOfPaymentsTakenPreviousYear
			
			--	, SUM(CASE WHEN P.CreatedToday = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenToday
			--	, SUM(CASE WHEN P.CreatedYesterday = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenYesterday
			--	, SUM(CASE WHEN P.CreatedThisWeek = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisWeek
			--	, SUM(CASE WHEN P.CreatedThisMonth = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisMonth
			--	, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenPreviousMonth
			--	, SUM(CASE WHEN P.CreatedThisYear = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenThisYear
			--	, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
			--				AND P.PaidByClientOnline = 'True' THEN 1 ELSE 0 END)				AS NumberOfOnlinePaymentsTakenPreviousYear
						
			--	, SUM(CASE WHEN P.CreatedToday = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenToday
			--	, SUM(CASE WHEN P.CreatedYesterday = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenYesterday
			--	, SUM(CASE WHEN P.CreatedThisWeek = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisWeek
			--	, SUM(CASE WHEN P.CreatedThisMonth = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisMonth
			--	, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenPreviousMonth
			--	, SUM(CASE WHEN P.CreatedThisYear = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenThisYear
			--	, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
			--				AND P.PaymentUnallocatedToClient = 'True' THEN 1 ELSE 0 END)		AS NumberOfUnallocatedPaymentsTakenPreviousYear
						
			--	, SUM(CASE WHEN P.CreatedToday = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenToday
			--	, SUM(CASE WHEN P.CreatedYesterday = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenYesterday
			--	, SUM(CASE WHEN P.CreatedThisWeek = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisWeek
			--	, SUM(CASE WHEN P.CreatedThisMonth = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisMonth
			--	, SUM(CASE WHEN P.CreatedPreviousMonth = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenPreviousMonth
			--	, SUM(CASE WHEN P.CreatedThisYear = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenThisYear
			--	, SUM(CASE WHEN P.CreatedPreviousYear = 'True'
			--				AND ISNULL(P.RefundPayment,'False') = 'True' THEN 1 ELSE 0 END)		AS NumberOfRefundedPaymentsTakenPreviousYear

			--	, SUM(CASE WHEN P.CreatedToday = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenToday
			--	, SUM(CASE WHEN P.CreatedYesterday = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenYesterday
			--	, SUM(CASE WHEN P.CreatedThisWeek = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenThisWeek
			--	, SUM(CASE WHEN P.CreatedThisMonth = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenThisMonth
			--	, SUM(CASE WHEN P.CreatedPreviousMonth = 'True' THEN P.PaymentAmount ELSE 0 END)	AS PaymentSumTakenPreviousMonth
			--	, SUM(CASE WHEN P.CreatedThisYear = 'True' THEN P.PaymentAmount ELSE 0 END)			AS PaymentSumTakenThisYear
			--	, SUM(CASE WHEN P.CreatedPreviousYear = 'True' THEN P.PaymentAmount ELSE 0 END)		AS PaymentSumTakenPreviousYear
			----FROM vwPaymentsLinksDetail P
			--FROM Organisation O
			--LEFT JOIN vwPaymentsLinksDetail P ON P.OrganisationId = O.Id
			--GROUP BY O.Id, O.[Name]
			--;
		GO
		/*********************************************************************************************************************/
		