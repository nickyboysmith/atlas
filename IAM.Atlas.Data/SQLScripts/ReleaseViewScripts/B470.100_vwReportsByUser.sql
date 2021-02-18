
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwReportsByUser', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportsByUser;
END		
GO

/*
	Create View vwReportsByUser
*/
CREATE VIEW vwReportsByUser
AS	
	-- Reports allocated to the Organisation
	SELECT  DISTINCT
		OU.OrganisationId							AS OrganisationId
		, O.[Name]									AS OrganisationName
		, OU.UserId									AS UserId
		, U.[Name]									AS UserName
		, RC.Title									AS ReportCategory
		, RC.[Disabled]								AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.OrganisationUser OU
	INNER JOIN dbo.Organisation O					ON O.Id = OU.OrganisationId
	INNER JOIN dbo.[User] U							ON U.Id = OU.UserId
	INNER JOIN dbo.OrganisationReport ORep			ON Orep.OrganisationId = ORep.OrganisationId
	INNER JOIN dbo.Report R							ON R.Id = ORep.ReportId
	INNER JOIN dbo.ReportsReportCategory RRC		ON RRC.ReportId = ORep.ReportId
	INNER JOIN dbo.ReportCategory RC				ON RC.Id = RRC.ReportCategoryId
	INNER JOIN dbo.OrganisationReportCategory ORCat	ON ORCat.OrganisationId = OU.OrganisationId
													AND ORCat.ReportCategoryId = RRC.ReportCategoryId
	UNION -- Reports Owned by a Specific User in the Organisation
	SELECT DISTINCT
		OU.OrganisationId							AS OrganisationId
		, O.[Name]									AS OrganisationName
		, OU.UserId									AS UserId
		, U.[Name]									AS UserName
		, RC.Title									AS ReportCategory
		, RC.[Disabled]								AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.OrganisationUser OU
	INNER JOIN dbo.Organisation O					ON O.Id = OU.OrganisationId
	INNER JOIN dbo.[User] U							ON U.Id = OU.UserId
	INNER JOIN dbo.ReportOwner RO					ON RO.UserId = OU.UserId
	INNER JOIN dbo.Report R							ON R.Id = RO.ReportId
	INNER JOIN dbo.ReportsReportCategory RRC		ON RRC.ReportId = RO.ReportId
	INNER JOIN dbo.ReportCategory RC				ON RC.Id = RRC.ReportCategoryId
	INNER JOIN dbo.OrganisationReportCategory ORCat	ON ORCat.OrganisationId = OU.OrganisationId
													AND ORCat.ReportCategoryId = RRC.ReportCategoryId
	UNION -- Reports Assigned to a Specific User
	SELECT DISTINCT
		OU.OrganisationId							AS OrganisationId
		, O.[Name]									AS OrganisationName
		, OU.UserId									AS UserId
		, U.[Name]									AS UserName
		, RC.Title									AS ReportCategory
		, RC.[Disabled]								AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.OrganisationUser OU
	INNER JOIN dbo.Organisation O					ON O.Id = OU.OrganisationId
	INNER JOIN dbo.[User] U							ON U.Id = OU.UserId
	INNER JOIN dbo.UserReport UR					ON UR.UserId = OU.UserId
	INNER JOIN dbo.Report R							ON R.Id = UR.ReportId
	INNER JOIN dbo.ReportsReportCategory RRC		ON RRC.ReportId = UR.ReportId
	INNER JOIN dbo.ReportCategory RC				ON RC.Id = RRC.ReportCategoryId
	INNER JOIN dbo.OrganisationReportCategory ORCat	ON ORCat.OrganisationId = OU.OrganisationId
													AND ORCat.ReportCategoryId = RRC.ReportCategoryId
	UNION --Reports that Trainers Have Access to
	SELECT DISTINCT
		TOrg.OrganisationId							AS OrganisationId
		, O.[Name]									AS OrganisationName
		, T.UserId									AS UserId
		, U.[Name]									AS UserName
		, RC.Title									AS ReportCategory
		, RC.[Disabled]								AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.TrainerOrganisation TOrg
	INNER JOIN dbo.Organisation O					ON O.Id = TOrg.OrganisationId
	INNER JOIN dbo.Trainer T						ON T.Id = TOrg.TrainerId
	INNER JOIN dbo.[User] U							ON U.Id = T.UserId
	INNER JOIN dbo.UserReport UR					ON UR.UserId = T.UserId
	INNER JOIN dbo.Report R							ON R.Id = UR.ReportId
	INNER JOIN dbo.ReportsReportCategory RRC		ON RRC.ReportId = UR.ReportId
	INNER JOIN dbo.ReportCategory RC				ON RC.Id = RRC.ReportCategoryId
	INNER JOIN dbo.OrganisationReportCategory ORCat	ON ORCat.OrganisationId = TOrg.OrganisationId
													AND ORCat.ReportCategoryId = RRC.ReportCategoryId
	UNION --System Administrators Have Access to All Reports in All Organisations
	SELECT DISTINCT
		O.Id										AS OrganisationId
		, O.[Name]									AS OrganisationName
		, U.Id										AS UserId
		, U.[Name]									AS UserName
		, R.ReportCategory							AS ReportCategory
		, R.ReportCategoryDisabled					AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.Organisation O
	CROSS JOIN (SELECT U2.*
				FROM dbo.SystemAdminUser SAU
				INNER JOIN dbo.[User] U2	ON U2.Id = SAU.UserId
				) U
	CROSS JOIN (SELECT ORCat.OrganisationId, RC.Title AS ReportCategory, RC.[Disabled] AS ReportCategoryDisabled, R2.*
				FROM dbo.Report R2
				INNER JOIN dbo.ReportsReportCategory RRC		ON RRC.ReportId = R2.Id
				INNER JOIN dbo.ReportCategory RC				ON RC.Id = RRC.ReportCategoryId
				INNER JOIN dbo.OrganisationReportCategory ORCat	ON ORCat.ReportCategoryId = RRC.ReportCategoryId
				) R
	WHERE R.OrganisationId = O.Id
	UNION --System Administrators Have Access to All Reports in All Organisations
	SELECT DISTINCT
		O.Id										AS OrganisationId
		, O.[Name]									AS OrganisationName
		, U.Id										AS UserId
		, U.[Name]									AS UserName
		, '*Non Categorised Reports*'				AS ReportCategory
		, CAST('False' AS BIT)						AS ReportCategoryDisabled
		, R.Id										AS ReportId
		, R.Title									AS ReportTitle
		, R.[Description]							AS ReportDescription
		, R.AtlasSystemReport						AS AtlasSystemReport
		, R.Landscape								AS Landscape
		, R.ChangeNo								AS ReportVersion
	FROM dbo.Organisation O
	CROSS JOIN (SELECT U2.*
				FROM dbo.SystemAdminUser SAU
				INNER JOIN dbo.[User] U2	ON U2.Id = SAU.UserId
				) U
	CROSS JOIN (SELECT R2.*
				FROM dbo.Report R2
				LEFT JOIN dbo.ReportsReportCategory RRC ON RRC.ReportId = R2.Id
				WHERE RRC.Id IS NULL) R
				
	;
	/*****************************************************************************************************************/
GO
