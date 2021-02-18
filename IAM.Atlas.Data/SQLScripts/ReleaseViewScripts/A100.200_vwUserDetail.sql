

--User Details
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwUserDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwUserDetail;
END		
GO
/*
	Create vwUserDetail
*/
CREATE VIEW vwUserDetail 
AS
	SELECT DISTINCT
		ISNULL(O.Id, 0)					AS OrganisationId
		, O.[Name]						AS Organisation
		, U.Id							AS UserId
		, U.[LoginId]					AS LoginId
		, U.[Name]						AS UserName
		, U.[Email]						AS Email
		, U.[Phone]						AS Phone
		, CAST((CASE WHEN OAU.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsAdministrator
		, CAST((CASE WHEN TOrg.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsTrainer
		, CAST((CASE WHEN OU.Id IS NOT NULL OR OAU.Id IS NOT NULL THEN 'True' ELSE 'False' END) AS BIT)		AS IsOrgUser
		, CAST((CASE WHEN SSU.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsSupportStaff
		, CAST((CASE WHEN RAU.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsReferringAuthorityStaff
		, CAST((CASE WHEN SAU.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsSystemAdministrator
		, CAST((CASE WHEN CL.Id IS NULL THEN 'False' ELSE 'True' END) AS BIT)								AS IsClient
		, SAU.CurrentlyProvidingSupport		AS IsSystemAdminSupport
		, RA.[Name]							AS ReferringAuthorityName
		, U.[GenderId]						AS GenderId
		, G.[Name]							AS Gender
		, U.LastLoginAttempt				AS LastLoginAttempt
		, ULSL.LastSuccessfulLogin			AS LastSuccessfulLogin
		, U.[Disabled]						AS [Disabled]
		, U.SecretQuestion					AS SecretQuestion
		, U.SecretAnswer					AS SecretAnswer
		, U.PasswordChangeRequired			AS PasswordChangeRequired
		, CAST(CASE WHEN MSA.UserId IS NOT NULL
				THEN 'True'
				ELSE 'False' END AS BIT)	AS IsMysteryShopperAdministrator
		, CAST(ISNULL(OSC.SystemIsReadOnly, 'False') AS BIT)				AS SystemIsReadOnly
	FROM [dbo].[User] U
	INNER JOIN [dbo].[Gender] G ON G.Id = U.[GenderId]
	LEFT JOIN [dbo].[OrganisationUser] OU ON OU.[UserId] = U.Id
	LEFT JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.[UserId] = U.Id
	LEFT JOIN [dbo].[SystemSupportUser] SSU ON SSU.[UserId] = U.Id
	LEFT JOIN [dbo].[ReferringAuthorityUser] RAU ON RAU.[UserId] = U.Id
	LEFT JOIN [dbo].ReferringAuthority RA ON RA.Id = RAU.ReferringAuthorityId
	LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.[UserId] = U.Id
	LEFT JOIN [dbo].[Client] CL ON CL.[UserId] = U.Id
	LEFT JOIN [dbo].[ClientOrganisation] COrg ON COrg.[ClientId] = CL.Id
	LEFT JOIN [dbo].[Trainer] T ON T.[UserId] = U.Id
	LEFT JOIN [dbo].[TrainerOrganisation] TOrg ON TOrg.[TrainerId] = T.Id
	LEFT JOIN [dbo].[Organisation] O ON O.Id = (CASE WHEN OU.OrganisationId IS NULL 
													THEN (CASE WHEN OAU.OrganisationId IS NULL 
																THEN (CASE WHEN TOrg.OrganisationId IS NULL THEN COrg.OrganisationId  ELSE TOrg.OrganisationId END) 
																ELSE OAU.OrganisationId END) 
													ELSE OU.OrganisationId END)
	LEFT JOIN [dbo].[OrganisationSystemConfiguration] OSC ON O.Id = OSC.OrganisationId
	LEFT JOIN dbo.vwUserLastSuccessfulLogin_SubView ULSL ON ULSL.UserId = U.Id
	LEFT JOIN dbo.MysteryShopperAdministrator MSA ON MSA.UserId = U.Id
	;
GO
/*********************************************************************************************************************/
