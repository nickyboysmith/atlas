
		-- Admin Menu Items View

		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwAdminMenuItems', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwAdminMenuItems;
		END		
		GO

		/*
			Create vwAdminMenuItems
		*/
		CREATE VIEW vwAdminMenuItems AS

		SELECT DISTINCT O.Id AS OrganisationId
			   , O.Name AS OrganisationName
			   , U.Id AS UserId
			   , U.[Name] AS UserName
			   , (CASE WHEN SAU.Id IS NOT NULL THEN 'True' ELSE 'False' END) AS SystemsAdmin
			   --       
			   --
			   , AMGI.[SortNumber] AS MenuGroupItemSortNumber
			   --
			   , AMI.Id AS MenuItemId
			   , AMI.Title AS MenuItemTitle
			   , AMI.Url AS MenuItemUrl
			   , AMI.Description AS MenuItemDescription
			   , AMI.Modal AS MenuItemModal
			   , AMI.Disabled AS MenuItemDisabled
			   , AMI.Controller AS MenuItemController
			   , AMI.Parameters AS MenuItemParameters
			   , AMI.Class AS MenuItemClass
			   , AMG.[Title] AS MenuGroupTitle
			   , AMG.[Description] AS MenuGroupDescription
			   , AMG.[ParentGroupId] AS MenuGroupParentGroupId
			   , AMG.[Id] AS MenuGroupId
			   , AMG.[SortNumber] AS MenuGroupSortNumber
			   --
		FROM [dbo].[User] U
		LEFT JOIN [dbo].[OrganisationUser] OU ON OU.[UserId] = U.Id
		LEFT JOIN [dbo].[Organisation] O ON O.Id = OU.[OrganisationId]
		LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.[UserId] = U.Id
		--------------
		LEFT JOIN [dbo].[AdministrationMenuItemUser] AMIU ON AMIU.[UserId] = U.[Id]
		--------------
		LEFT JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.[OrganisationId] = O.Id
																				   AND OAU.[UserId] = U.[Id]
		LEFT JOIN [dbo].[AdministrationMenuItemOrganisation] AMIO ON AMIO.[OrganisationId] = OAU.[OrganisationId]
		LEFT JOIN [dbo].[AdministrationMenuItem] AMI ON AMI.Id = AMIO.[AdminMenuItemId]
																								 OR SAU.Id IS NOT NULL
																								 OR AMI.Id = AMIU.[AdminMenuItemId]
		--------------
		INNER JOIN [dbo].[AdministrationMenuGroupItem] AMGI ON AMGI.[AdminMenuItemId] = AMI.Id
		INNER JOIN [dbo].[AdministrationMenuGroup] AMG ON AMG.[Id] = AMGI.[AdminMenuGroupId]

		WHERE (OU.Id IS NOT NULL OR SAU.Id IS NOT NULL)
		AND AMI.Id IS NOT NULL

		GO
		/*********************************************************************************************************************/
		