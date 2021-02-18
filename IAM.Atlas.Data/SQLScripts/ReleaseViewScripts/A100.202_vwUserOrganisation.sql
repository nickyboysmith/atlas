
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwUserOrganisation', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwUserOrganisation;
END		
GO
/*
	Create vwUserOrganisation
*/
CREATE VIEW vwUserOrganisation
AS
	SELECT 
		U.Id							AS UserId
		, U.[LoginId]					AS LoginId
		, U.[Name]						AS UserName
		, OU.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, O.Active						AS OrganisationActive
	FROM dbo.[User] U
	INNER JOIN dbo.OrganisationUser OU ON OU.UserId = U.Id
	INNER JOIN dbo.Organisation O ON O.Id = OU.OrganisationId
	;
GO
/*********************************************************************************************************************/
