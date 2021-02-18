
		--- DashboardMeter User Access View

		/*
			Drop the Procedure if it already exists
		*/	
		IF OBJECT_ID('dbo.vwDashboardMeter_UserAccess', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwDashboardMeter_UserAccess;
		END		
		GO

		/*
			Create View vwDashboardMeter_UserAccess
		*/
		CREATE VIEW dbo.vwDashboardMeter_UserAccess 
		AS
			SELECT DISTINCT
				U.Id						AS UserId
				, U.[Name]					AS UserDisplayName
				, DM.Id						AS DashboardMeterId
				, DM.[Name]					AS DashboardMeterName
				, DM.Title					AS DashboardMeterTitle
				, DM.[Description]			AS DashboardMeterDescription
				, DM.RefreshRate			AS DashboardMeterRefreshRate
				, DMC.[Name]				AS DashboardMeterCategory
				, DMC.[Id]					AS DashboardMeterCategoryId
				, DMC.[PictureName]			AS DashboardMeterCategoryPicture
			FROM [User] U
			INNER JOIN OrganisationUser OU					ON OU.UserId = U.Id
			INNER JOIN Organisation O						ON O.Id = OU.OrganisationId
			INNER JOIN OrganisationDashboardMeter ODM		ON ODM.OrganisationId = OU.OrganisationId
			INNER JOIN DashboardMeter DM					ON DM.Id = ODM.DashboardMeterId
															AND DM.[Disabled] = 'False'
			INNER JOIN [dbo].[DashboardMeterCategory] DMC	ON DMC.[Id] = DM.[DashboardMeterCategoryId]
			INNER JOIN [dbo].[DashboardMeterExposure] DME	ON DME.[DashboardMeterId] = DM.Id
															AND DME.OrganisationId = O.Id
			WHERE ISNULL(U.[Disabled],'False') = 'False' 
			AND DM.Id IS NOT NULL
			UNION
			SELECT DISTINCT
				U.Id						AS UserId
				, U.[Name]					AS UserDisplayName
				, DM.Id                     AS DashboardMeterId
				, DM.[Name]					AS DashboardMeterName
				, DM.Title					AS DashboardMeterTitle
				, DM.[Description]			AS DashboardMeterDescription
				, DM.RefreshRate			AS DashboardMeterRefreshRate
				, DMC.[Name]				AS DashboardMeterCategory
				, DMC.[Id]					AS DashboardMeterCategoryId
				, DMC.[PictureName]			AS DashboardMeterCategoryPicture
			FROM [User] U
			LEFT JOIN UserDashboardMeter UDM	ON UDM.UserId = U.Id
			LEFT JOIN DashboardMeter DM			ON DM.Id = UDM.DashboardMeterId
												AND DM.[Disabled] = 'False'
			LEFT JOIN [dbo].[DashboardMeterCategory] DMC	ON DMC.[Id] = DM.[DashboardMeterCategoryId]
			WHERE ISNULL(U.[Disabled],'False') = 'False' 
			AND DM.Id IS NOT NULL;
			
		GO	

				
		/*********************************************************************************************************************/
