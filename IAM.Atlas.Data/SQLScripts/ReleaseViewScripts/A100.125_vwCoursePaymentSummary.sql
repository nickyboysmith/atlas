	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwCoursePaymentSummary', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.[vwCoursePaymentSummary];
	END		
	GO

	/*
		Create View [vwCoursePaymentSummary]
	*/
	CREATE VIEW [vwCoursePaymentSummary] AS

			SELECT C.Id AS CourseId
				, Count(CCP.PaymentId) AS NumberOfPayments
				, SUM((CASE WHEN P.[Refund] = 'True' 
							THEN (P.[Amount] * -1)
							ELSE P.[Amount] 
							END)) AS TotalPaymentAmount
				, SUM(CC.TotalPaymentDue) AS TotalPaymentDue
			FROM CourseClientPayment CCP
			INNER JOIN Course C ON CCP.CourseId = C.Id --This is only added so entity framework picks up the view
			INNER JOIN [dbo].[Payment] P ON P.Id = CCP.[PaymentId]
			LEFT JOIN [dbo].[CourseClient] CC ON CC.CourseId = CCP.CourseId
												AND CC.ClientId = CCP.ClientId
			GROUP BY C.Id;

	GO

		/*****************************************************************************************************************/