
		--Create Sub View vwCourseClientPaymentSummary_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseClientPaymentSummary_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientPaymentSummary_SubView;
		END		
		GO

		/*
			Create vwCourseClientPaymentSummary_SubView
			NB. This view is used within view "vwCourseDetail"
		*/
		CREATE VIEW vwCourseClientPaymentSummary_SubView
		AS
			SELECT CCP.Courseid
				, CCP.ClientId
				, Count(CCP.PaymentId) AS NumberOfPayments
				, SUM((CASE WHEN P.[Refund] = 'True' 
							THEN (P.[Amount] * -1)
							ELSE P.[Amount] 
							END)) AS TotalPaymentAmount
				, SUM(CC.TotalPaymentDue) AS TotalPaymentDue
			FROM CourseClientPayment CCP
			INNER JOIN [dbo].[Payment] P ON P.Id = CCP.[PaymentId]
			LEFT JOIN [dbo].[CourseClient] CC ON CC.CourseId = CCP.CourseId
												AND CC.ClientId = CCP.ClientId
			GROUP BY CCP.CourseId, CCP.ClientId;
		GO
		
		/*********************************************************************************************************************/
		