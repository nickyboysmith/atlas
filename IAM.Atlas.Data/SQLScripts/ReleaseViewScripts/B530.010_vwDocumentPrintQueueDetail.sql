
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDocumentPrintQueueDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDocumentPrintQueueDetail;
END		
GO

CREATE VIEW [dbo].[vwDocumentPrintQueueDetail]
AS
	SELECT 
		DPQ.[OrganisationId]				AS OrganisationId
		, O.[Name]							AS OrganisationName
		, DPQ.[DocumentId]					AS DocumentId
		, D.[Title]							AS Document
		, DPQ.[DateCreated]					AS DocumentDateAdded
		, D.[Type]							AS DocumentType
		, DPQ.[QueueInfo]					AS QueueInformation
		, DPQ.[CreatedByUserId]				AS CreatedByUserId
		, U.[Name]							AS CreatedByUser
	FROM [dbo].[DocumentPrintQueue] DPQ
	INNER JOIN dbo.[Organisation] O				ON O.Id = DPQ.OrganisationId
	INNER JOIN dbo.[Document] D					ON D.Id = DPQ.DocumentId
	INNER JOIN dbo.[User] U						ON U.Id = DPQ.CreatedByUserId
	;
GO

/*********************************************************************************************************************/