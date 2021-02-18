/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportsVenueDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportsVenueDetail;
END		
GO

/*
	Create vwReportsVenueDetail
*/
CREATE VIEW vwReportsVenueDetail
AS
	SELECT DISTINCT
		OCO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, VD.Id							AS Id
		, VD.Code						AS Code
		, VD.Title
			+ ' (' + REG.[Name] + ')'	AS Title
		, VD.ExtendedTitle				AS ExtendedTitle
		, VD.Description				AS Description
		, VD.Notes						AS Notes
		, VD.Prefix						AS Prefix
		, VD.Enabled					AS Enabled
		, VD.Address					AS Address
		, VD.PostCode					AS PostCode
		, VD.Cost						AS Cost
		, VD.AdditionalInformation		AS AdditionalInformation
		, VD.DORSVenue					AS DORSVenue
	FROM dbo.OrganisationCourse OCO
	INNER JOIN dbo.Organisation O		ON O.Id = OCO.OrganisationId
	INNER JOIN dbo.CourseVenue COV		ON COV.CourseId = OCO.CourseId
	INNER JOIN dbo.vwVenueDetail VD		ON VD.Id = COV.VenueId
	INNER JOIN dbo.VenueRegion VR		ON VR.VenueId = COV.VenueId
	INNER JOIN dbo.Region REG			ON REG.Id = VR.RegionId
	;

GO

/*********************************************************************************************************************/
