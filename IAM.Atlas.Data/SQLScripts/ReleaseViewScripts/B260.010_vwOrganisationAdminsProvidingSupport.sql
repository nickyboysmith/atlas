/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwOrganisationAdminsProvidingSupport', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwOrganisationAdminsProvidingSupport;
END		
GO

/*
	Create vwOrganisationAdminsProvidingSupport
*/
CREATE VIEW dbo.vwOrganisationAdminsProvidingSupport
AS
	SELECT 
		O.Id				AS OrganisationId
		, O.[Name]			AS OrganisationNAme
		, SSU.UserId		AS UserId
		, U.[Name]			AS [Name]
		, U.Email			AS Email
		, U.Phone			AS PhoneNumber
	FROM dbo.Organisation O
	INNER JOIN dbo.SystemSupportUser SSU		ON SSU.OrganisationId = O.Id
	INNER JOIN dbo.[User] U						ON U.Id = SSU.UserId
	WHERE ISNULL(U.[Disabled], 'False') = 'False';
	
GO

/*********************************************************************************************************************/


