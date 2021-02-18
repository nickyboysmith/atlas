

		

--vwRefundRequest
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwRefundRequest', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwRefundRequest;
END		
GO
/*
	Create vwRefundRequest
*/
CREATE VIEW vwRefundRequest
AS
	SELECT 
		RR.Id									AS RefundRequestId
		, RR.DateCreated						AS DateCreated
		, RR.RequestDate						AS RefundRequestDate
		, RR.RelatedPaymentId					AS RelatedPaymentId
		, P.PaymentTypeId						AS RelatedPaymentTypeId
		, PT.[Name]								AS RelatedPaymentType
		, P.PaymentMethodId						AS RelatedPaymentMethodId
		, PM.[Name]								AS RelatedPaymentMethod
		, P.Amount								AS RelatedPaymentAmount
		, P.CardPayment							AS RelatedPaymentWasCardPayment
		, P.PaymentName							AS RelatedPaymentName
		, P.TransactionDate						AS RelatedPaymentTransactionDate
		, P.Reference							AS RelatedPaymentReference
		, P.ReceiptNumber						AS RelatedPaymentReceiptNumber
		, P.AuthCode							AS RelatedPaymentAuthCode
		, RR.RelatedCourseId					AS RelatedCourseId
		, CT.Title								AS RelatedCourseType
		, CT.Id									AS RelatedCourseTypeId
		, CTC.Id								AS RelatedCourseTypeCategoryId
		, CTC.[Name]							AS RelatedCourseTypeCategory
		, COU.Reference							AS RelatedCourseReference
		, CD.StartDate							AS RelatedCourseStartDate
		, CD.EndDate							AS RelatedCourseEndDate
		, V.Title								AS RelatedCourseVenueTitle
		, RR.RelatedClientId					AS RelatedClientId
		, CL.DisplayName						AS RelatedClientName
		, CL.DateOfBirth						AS RelatedClientDateOfBirth
		, RR.Amount								AS RequestedRefundAmount
		, RR.RefundMethodId						AS RefundMethodId
		, RM.[Name]								AS RefundMethod
		, RR.RefundTypeId						AS RefundTypeId
		, RT.[Name]								AS RefundType
		, RR.CreatedByUserId					AS RequestCreatedByUserId
		, U.[Name]								AS RequestCreatedByUserName
		, U.Email								AS RequestCreatedByUserEmail
		, RR.Reference							AS RefundRequestReference
		, RR.PaymentName						AS RefundRequestPaymentName
		, RR.OrganisationId						AS RefundRequestOrganisationId
		, O.[Name]								AS RefundRequestOrganisationName
		, RR.RequestSentDate					AS RefundRequestSentDate
		, RR.DateRequestDone					AS RefundDateRequestDone
		, RR.RequestDoneByUserId				AS RefundRequestDoneByUserId
		, U2.[Name]								AS RequestDoneByUserName
		, U2.Email								AS RequestDoneByUserEmail
		, (CAST ((CASE WHEN CRR.Id IS NULL
					THEN 'False' 
					ELSE 'True' END)
				AS BIT))						AS RequestCancelled
		, CRR.DateCancellationNotificationSent  AS DateCancellationNotificationSent
		, CRR.CancellationReason				AS CancellationReason
		, RR.RequestDone						AS RequestCompleted
		, RRN.Notes								AS RefundRequestNotes
	FROM dbo.RefundRequest RR
	LEFT JOIN dbo.Payment P									ON P.Id = RR.RelatedPaymentId
	LEFT JOIN dbo.PaymentType PT							ON PT.Id = P.PaymentTypeId
	LEFT JOIN dbo.PaymentMethod PM							ON PM.Id = P.PaymentMethodId
	LEFT JOIN [dbo].[Course] COU							ON COU.Id = RR.RelatedCourseId
	LEFT JOIN [dbo].[vwCourseDates_SubView] CD				ON CD.CourseId = RR.RelatedCourseId
	LEFT JOIN [dbo].[CourseType] CT							ON CT.Id = COU.CourseTypeId
	LEFT JOIN [dbo].[CourseTypeCategory] CTC				ON CTC.Id = COU.CourseTypeCategoryId	
	LEFT JOIN [dbo].[CourseVenue] CV						ON CV.CourseId = RR.RelatedCourseId
	LEFT JOIN [dbo].[Venue] V								ON V.Id = CV.VenueId
	LEFT JOIN [dbo].[Client] CL								ON CL.Id = RR.RelatedClientId
	LEFT JOIN dbo.RefundMethod RM							ON RM.Id = RR.RefundMethodId
	LEFT JOIN dbo.RefundType RT								ON RT.Id = RR.RefundTypeId
	LEFT JOIN dbo.[User] U									ON U.Id = RR.CreatedByUserId
	LEFT JOIN dbo.[User] U2									ON U2.Id = RR.RequestDoneByUserId
	LEFT JOIN vwRefundRequestNotes_SubView RRN				ON RRN.RefundRequestId = RR.Id
	LEFT JOIN dbo.CancelledRefundRequest CRR				ON CRR.RefundRequestId = RR.Id
	LEFT JOIN dbo.Organisation O							ON O.Id = RR.OrganisationId
	;
	
GO


/*********************************************************************************************************************/