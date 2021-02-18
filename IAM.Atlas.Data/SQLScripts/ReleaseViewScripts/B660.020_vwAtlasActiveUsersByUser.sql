/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwAtlasActiveUsersByUser', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwAtlasActiveUsersByUser;
END		
GO

/*
	Create vwAtlasActiveUsersByUser
*/
CREATE VIEW vwAtlasActiveUsersByUser
AS
	SELECT
			ISNULL(T.OrganisationId, -1)			AS OrganisationId
			, T.OrganisationName					AS OrganisationName
			, ISNULL(T.UserId, -1)					AS UserId
			, T.UserName							AS UserName
			, T.LoginId								AS LoginId
			, T.ActiveUserOrganisationId			AS ActiveUserOrganisationId
			, T.ActiveUserOrganisationName			AS ActiveUserOrganisationName
			, ISNULL(T.ActiveUserId, -1)			AS ActiveUserId
			, T.ActiveUserName						AS ActiveUserName
			, T.ActiveUserLoginId					AS ActiveUserLoginId
			, T.LoggedInTime						AS LoggedInTime
	FROM (
		SELECT 
			OU.OrganisationId						AS OrganisationId
			, O.[Name]								AS OrganisationName
			, OU.UserId								AS UserId
			, U.[Name]								AS UserName
			, U.LoginId								AS LoginId
			, OU2.OrganisationId					AS ActiveUserOrganisationId
			, O2.[Name]								AS ActiveUserOrganisationName
			, OU2.UserId							AS ActiveUserId
			, (CASE WHEN U.Id = U2.Id
					THEN U2.[Name] + ' (Current User)'
					ELSE U2.[Name]
					END)							AS ActiveUserName
			, U2.LoginId							AS ActiveUserLoginId
			, LS.IssuedOn							AS LoggedInTime
		FROM dbo.OrganisationUser OU
		INNER JOIN dbo.Organisation O				ON O.Id = OU.OrganisationId
		INNER JOIN dbo.[User] U						ON U.Id = OU.UserId
		INNER JOIN dbo.OrganisationUser OU2			ON OU2.OrganisationId = OU.OrganisationId
		INNER JOIN dbo.Organisation O2				ON O2.Id = OU2.OrganisationId
		INNER JOIN dbo.LoginSession LS				ON LS.UserId = OU2.UserId
		INNER JOIN dbo.[User] U2					ON U2.Id = OU2.UserId
		LEFT JOIN dbo.SystemAdminUser SAU			ON SAU.UserId = U2.Id
		WHERE LS.ExpiresOn > GETDATE()
		AND SAU.Id IS NULL
		UNION
		SELECT 
			-1										AS OrganisationId
			, 'Atlas'								AS OrganisationName
			, SAU.UserId							AS UserId
			, U.[Name] + ' (SA)'					AS UserName
			, U.LoginId								AS LoginId
			, OU2.OrganisationId					AS ActiveUserOrganisationId
			, O2.[Name]								AS ActiveUserOrganisationName
			, OU2.UserId							AS ActiveUserId
			, (CASE WHEN U.Id = U2.Id
					THEN U2.[Name] + ' (Current User)'
					ELSE O2.[Name] + ' - ' + U2.[Name]
					END)							AS ActiveUserName
			, U2.LoginId							AS ActiveUserLoginId
			, LS.IssuedOn							AS LoggedInTime
		FROM dbo.SystemAdminUser SAU
		INNER JOIN dbo.[User] U						ON U.Id = SAU.UserId
		CROSS JOIN dbo.OrganisationUser OU2
		INNER JOIN dbo.Organisation O2				ON O2.Id = OU2.OrganisationId
		INNER JOIN dbo.LoginSession LS				ON LS.UserId = OU2.UserId
		INNER JOIN dbo.[User] U2					ON U2.Id = OU2.UserId
		WHERE LS.ExpiresOn > GETDATE()
		UNION
		SELECT 
			-1										AS OrganisationId
			, 'Atlas'								AS OrganisationName
			, SAU.UserId							AS UserId
			, U.[Name] + ' (SA)'					AS UserName
			, U.LoginId								AS LoginId
			, -1									AS ActiveUserOrganisationId
			, 'Atlas'								AS ActiveUserOrganisationName
			, SAU2.UserId							AS ActiveUserId
			, (CASE WHEN U.Id = U2.Id
					THEN U2.[Name] + ' (Current User)'
					ELSE U2.[Name] + ' (SA)'
					END)							AS ActiveUserName
			, U2.LoginId							AS ActiveUserLoginId
			, LS.IssuedOn							AS LoggedInTime
		FROM dbo.SystemAdminUser SAU
		INNER JOIN dbo.[User] U						ON U.Id = SAU.UserId
		CROSS JOIN dbo.SystemAdminUser SAU2
		INNER JOIN dbo.LoginSession LS				ON LS.UserId = SAU2.UserId
		INNER JOIN dbo.[User] U2					ON U2.Id = SAU2.UserId
		WHERE LS.ExpiresOn > GETDATE()
	) T
	;

GO

/*********************************************************************************************************************/

