
--Client History Event Types
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientHistoryEventType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientHistoryEventType;
END		
GO
/*
	Create vwClientHistoryEventType
*/
CREATE VIEW vwClientHistoryEventType 
AS
	/**********************************************************************************************/
	SELECT DISTINCT
		OrganisationId
		, OrganisationName
		, ClientId
		, ClientName
		, EventType
	FROM [dbo].vwClientHistory	
	;
GO
/*********************************************************************************************************************/