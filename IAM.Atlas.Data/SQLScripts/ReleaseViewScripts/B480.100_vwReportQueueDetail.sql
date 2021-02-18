
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportQueueDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportQueueDetail;
END		
GO

CREATE VIEW dbo.vwReportQueueDetail
AS
	SELECT 
		RQ.[OrganisationId]					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, RQ.[CreatedByUserId]				AS ListOwnerUserId
		, U.[Name]							AS ListOwner
		, RR.ReportId						AS ReportId
		, R.Title							AS ReportTitle
		, RR.Id								AS ReporRequestId
	FROM [dbo].[ReportQueue] RQ
	INNER JOIN dbo.[Organisation] O							ON O.Id = RQ.[OrganisationId]
	INNER JOIN dbo.[User] U									ON U.Id = RQ.[CreatedByUserId]
	INNER JOIN [dbo].[ReportQueueRequest] RQR				ON RQR.[ReportQueueId] = RQ.[Id]
	INNER JOIN [dbo].[ReportRequest] RR						ON RR.Id = RQR.[ReportRequestId]
	INNER JOIN dbo.[Report] R								ON R.Id = RR.ReportId
	;
GO

/*********************************************************************************************************************/