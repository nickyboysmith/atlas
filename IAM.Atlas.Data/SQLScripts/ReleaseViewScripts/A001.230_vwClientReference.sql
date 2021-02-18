
--Client Reference
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientReference', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientReference;
END		
GO
/*
	Create vwClientReference
*/
CREATE VIEW vwClientReference 
AS		
	SELECT O.Id									AS OrganisationId
		, O.[Name]								AS OrganisationName
		, C.Id									AS ClientId
		, C.DisplayName							AS ClientName
		, CR1.Reference							AS ClientPoliceReference
		, CR2.Reference							AS ClientOtherReference
	FROM dbo.Organisation O
	INNER JOIN dbo.ClientOrganisation CO			ON CO.OrganisationId = O.Id
	INNER JOIN dbo.Client C							ON C.Id = CO.ClientId
	LEFT JOIN dbo.ClientReference CR1				ON CR1.ClientId = CO.ClientId
													AND CR1.IsPoliceReference = 'True'
	LEFT JOIN dbo.ClientReference CR2				ON CR2.ClientId = CO.ClientId
													AND CR2.IsPoliceReference = 'False'
	;
GO
/*********************************************************************************************************************/
		