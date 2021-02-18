
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDocumentPrintQueueSummary', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDocumentPrintQueueSummary;
END		
GO

CREATE VIEW dbo.vwDocumentPrintQueueSummary
AS
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, COUNT(DPQD.[DocumentId])		AS DocumentsInQueue
	FROM dbo.[Organisation] O
	LEFT JOIN [dbo].[vwDocumentPrintQueueDetail] DPQD ON DPQD.OrganisationId = O.Id
	GROUP BY O.Id, O.[Name]
	;
GO

/*********************************************************************************************************************/
