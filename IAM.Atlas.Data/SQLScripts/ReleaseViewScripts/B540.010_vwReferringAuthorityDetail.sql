
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReferringAuthorityDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReferringAuthorityDetail;
END		
GO

CREATE VIEW dbo.vwReferringAuthorityDetail
AS
	SELECT 
		RA.Id									AS ReferringAuthorityId
		, RA.[Name]								AS ReferringAuthorityName
		, RA.[Description]						AS ReferringAuthorityDescription
		, RA.[Disabled]							AS [Disabled]
		, RA.AssociatedOrganisationId			AS AssociatedOrganisationId
		, O.[Name]								AS AssociatedOrganisation
		, RA.DORSForceId						AS DORSForceId
		, DF.[Name]								AS DORSForceName
		, DF.DORSForceIdentifier				AS DORSForceIdentifier
		, DF.PNCCode							AS DORSForcePNCCode
	FROM dbo.[ReferringAuthority] RA
	LEFT JOIN dbo.Organisation O				ON O.Id = RA.AssociatedOrganisationId
	LEFT JOIN dbo.DORSForce DF					ON DF.Id = RA.DORSForceId
	;
GO

/*********************************************************************************************************************/
