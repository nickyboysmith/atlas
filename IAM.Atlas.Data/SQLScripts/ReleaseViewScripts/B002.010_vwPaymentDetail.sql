/*********************************************************************************************************************/
		
-- Payments List
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwPaymentDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwPaymentDetail;
END		
GO

/*
	Create vwPaymentDetail
*/
CREATE VIEW vwPaymentDetail
AS
	SELECT
		P.Id									AS PaymentId
		, O.Id									AS OrganisationId
		, O.[Name]								AS OrganisationName
		, P.TransactionDate						AS TransactionDate
		, (CAST((CASE WHEN CAST(P.TransactionDate AS DATE) = CAST(GETDATE() AS DATE) 
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsToday
		, (CAST((CASE WHEN CAST(P.TransactionDate AS DATE) = CAST((GETDATE() - 1) AS DATE) 
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsYesterday
		, (CAST((CASE WHEN DATEPART(WEEK, P.TransactionDate) = DATEPART(WEEK, GETDATE()) 
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsThisWeek
		, (CAST((CASE WHEN DATEPART(MONTH, P.TransactionDate) = DATEPART(MONTH, GETDATE()) 
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsThisMonth
		, (CAST((CASE WHEN DATEPART(MONTH, P.TransactionDate) = DATEPART(MONTH, DATEADD(MONTH, -1, GETDATE()))
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsPreviousMonth
		, (CAST((CASE WHEN DATEPART(MONTH, P.TransactionDate) = DATEPART(MONTH, DATEADD(MONTH, -2, GETDATE()))
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsTwoMonthsAgo
		, (CAST((CASE WHEN DATEPART(YEAR, P.TransactionDate) = DATEPART(YEAR, GETDATE()) 
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsThisYear
		, (CAST((CASE WHEN DATEPART(YEAR, P.TransactionDate) = DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE()))
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentsPreviousYear
		, P.DateCreated							AS DateCreated
		, P.PaymentTypeId						AS PaymentTypeId
		, PT.[Name]								AS PaymentTypeName
		, P.PaymentMethodId						AS PaymentMethodId
		, PM.[Name]								AS PaymentMethodName
		, P.Amount								AS PaymentAmount
		, P.Refund								AS RefundPayment
		, P.CardPayment							AS CardPayment
		, P.PaymentName							AS PaymentName
		, P.Reference							AS PaymentReference
		, (CASE WHEN ISNULL(P.Refund, 'False') = 'True'
				THEN 'Refunded Payment.'
					+ ' Original Payment Id: "' + CAST(ISNULL(RP.[PaymentId], -1) AS VARCHAR) + '"'
					+ ' Original Payment Amount: "' + CAST(ISNULL(P2.Amount, 0) AS VARCHAR) + '"'
				ELSE '' END)
												AS PaymentAdditionalInfo
		, P.ReceiptNumber						AS PaymentReceiptNumber
		, P.AuthCode							AS PaymentAuthCode
		, PN.Notes								AS PaymentNotes
		, P.CreatedByUserId						AS PaymentRecordedByUserId
		, U.[Name]								AS PaymentRecordedByUser
		, CP.ClientId							AS ClientId
		, CL.DisplayName						AS ClientName
		, CL.DateOfBirth						AS ClientDateOfBirth
		, CR.ClientPoliceReference				AS ClientPoliceReference
		, CR.ClientOtherReference				AS ClientOtherReference
		, CCP.CourseId							AS CourseId
		, CT.Title								AS CourseType
		, CT.Id									AS CourseTypeId
		, CTC.Id								AS CourseTypeCategoryId
		, CTC.[Name]							AS CourseTypeCategory
		, COU.Reference							AS CourseReference
		, CD.StartDate							AS CourseStartDate
		, CD.EndDate							AS CourseEndDate
		, V.Title								AS VenueTitle
		, (CASE WHEN CCR.Id IS NULL 
				THEN ''
				ELSE 'Client Removed From Course ' + CONVERT(nvarchar(MAX), CCR.DateRemoved, 100)
				END)							AS CourseAdditionalInfo
		, (CAST((CASE WHEN CP.Id IS NULL
				THEN 'True' 
				ELSE 'False' 
				END) AS BIT))					As PaymentUnallocatedToClient
		, RP.RefundId							AS RefundId
	FROM OrganisationPayment OP
	INNER JOIN [dbo].[Organisation] O						ON O.Id = OP.OrganisationId
	INNER JOIN [dbo].[OrganisationSystemConfiguration] OSC	ON OSC.OrganisationId = OP.OrganisationId
	INNER JOIN [dbo].[Payment] P							ON P.Id = OP.PaymentId
	INNER JOIN [dbo].[User] U									ON U.Id = P.CreatedByUserId
	LEFT JOIN [dbo].[PaymentType] PT						ON PT.Id = P.PaymentTypeId
	LEFT JOIN [dbo].[PaymentMethod] PM						ON PM.Id = P.PaymentMethodId
	LEFT JOIN [dbo].[ClientPayment] CP						ON CP.[PaymentId] = OP.PaymentId
	LEFT JOIN [dbo].[Client] CL								ON CL.Id = CP.ClientId
	LEFT JOIN [dbo].[CourseClientPayment] CCP				ON CCP.PaymentId = OP.PaymentId
															AND CCP.ClientId = CP.ClientId
	LEFT JOIN dbo.vwClientReference CR						ON CR.[OrganisationId] = OP.OrganisationId
															AND CR.[ClientId] = CP.ClientId
	LEFT JOIN [dbo].[Course] COU							ON COU.Id = CCP.CourseId
	LEFT JOIN [dbo].[vwCourseDates_SubView] CD				ON CD.CourseId = CCP.CourseId
	LEFT JOIN [dbo].[CourseType] CT							ON CT.Id = COU.CourseTypeId
	LEFT JOIN [dbo].[CourseTypeCategory] CTC				ON CTC.Id = COU.CourseTypeCategoryId	
	LEFT JOIN [dbo].[CourseVenue] CV						ON CV.CourseId = CCP.CourseId
	LEFT JOIN [dbo].[Venue] V								ON V.Id = CV.VenueId
	LEFT JOIN [dbo].[CourseClient] CCL						ON CCL.CourseId = CCP.CourseId
															AND CCL.ClientId = CP.ClientId
	LEFT JOIN [dbo].[CourseClientRemoved] CCR				ON CCR.CourseClientId = CCL.Id
	LEFT JOIN [dbo].[vwPaymentNotes_SubView] PN				ON PN.PaymentId = OP.PaymentId
	LEFT JOIN [dbo].[RefundPayment] RP						ON RP.[RefundPaymentId] = OP.PaymentId
	LEFT JOIN [dbo].[Payment] P2							ON P2.Id = RP.[PaymentId]
	WHERE P.[TransactionDate] >= CAST(DATEADD(YEAR, -1 * ISNULL(OSC.YearsOfPaymentData, 3), GetDate()) AS DATE)
			
	;


GO