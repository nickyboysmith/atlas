/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwSystemAdminsNotProvidingAtlasSupport', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwSystemAdminsNotProvidingAtlasSupport;
END		
GO

/*
	Create vwSystemAdminsNotProvidingAtlasSupport
*/
CREATE VIEW dbo.vwSystemAdminsNotProvidingAtlasSupport
AS
	SELECT 
		SAU.UserId			AS UserId
		, U.[Name]			AS [Name]
		, U.Email			AS Email
		, U.Phone			AS PhoneNumber
	FROM dbo.SystemAdminUser SAU
	INNER JOIN dbo.[User] U				ON U.Id = SAU.UserId
	WHERE SAU.CurrentlyProvidingSupport = 'False'
	AND ISNULL(U.[Disabled], 'False') = 'False' 
	
GO

/*********************************************************************************************************************/


