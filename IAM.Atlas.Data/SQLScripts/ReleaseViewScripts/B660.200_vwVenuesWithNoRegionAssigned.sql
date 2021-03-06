/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwVenuesWithNoRegionAssigned', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwVenuesWithNoRegionAssigned;
END		
GO

/*
	Create View vwVenuesWithNoRegionAssigned
*/

CREATE VIEW dbo.vwVenuesWithNoRegionAssigned
AS
	SELECT 
		V.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, V.[Id]						AS VenueId
		, V.[Title]						AS VenueTitle
		, V.[Description]				AS VenueDescription
		, V.[Notes]						AS VenueNotes
		, V.[Prefix]					AS VenuePrefix
		, V.[Enabled]					AS VenueEnabled
		, V.[Code]						AS VenueCode
		, V.[DORSVenue]					AS DORSVenue
	FROM dbo.Venue V
	INNER JOIN dbo.Organisation O			ON O.Id = V.OrganisationId
	LEFT JOIN dbo.VenueRegion VR			ON VR.VenueId = V.Id
	WHERE VR.Id IS NULL
	AND V.[Enabled] = 'True'
	;
GO
	
/*********************************************************************************************************************/

