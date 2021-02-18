

--vwRefundRequest
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwRefundRequestRemindersDue', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwRefundRequestRemindersDue;
END		
GO
/*
	Create vwRefundRequestRemindersDue
*/
CREATE VIEW vwRefundRequestRemindersDue
AS
	SELECT 
		RefundRequestId
		, DateCreated
		, RefundRequestDate
		, RelatedPaymentName
		, RequestedRefundAmount
	FROM dbo.vwRefundRequest
	WHERE [RequestCompleted] = 'False'
	AND ISNULL([RequestCancelled], 'False') = 'False'
	AND DATEADD(DAY, 2, [RefundRequestSentDate]) <= GETDATE() /* IE Reminders Due Every Two Days */
	;
	
GO


/*********************************************************************************************************************/