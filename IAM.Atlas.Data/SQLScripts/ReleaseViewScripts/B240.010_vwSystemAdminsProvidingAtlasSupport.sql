/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwSystemAdminsProvidingAtlasSupport', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwSystemAdminsProvidingAtlasSupport;
END		
GO

/*
	Create vwSystemAdminsProvidingAtlasSupport
*/
CREATE VIEW dbo.vwSystemAdminsProvidingAtlasSupport
AS
	SELECT 
		SAU.UserId			AS UserId
		, U.[Name]			AS [Name]
		, U.Email			AS Email
		, U.Phone			AS PhoneNumber
	FROM dbo.SystemAdminUser SAU
	INNER JOIN dbo.[User] U				ON U.Id = SAU.UserId
	WHERE SAU.CurrentlyProvidingSupport = 'True'
	AND ISNULL(U.[Disabled], 'False') = 'False';
	
GO

/*********************************************************************************************************************/


