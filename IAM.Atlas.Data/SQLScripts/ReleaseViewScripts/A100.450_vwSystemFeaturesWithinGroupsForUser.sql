
		-- System Features Within Groups
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwSystemFeaturesWithinGroupsForUser', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwSystemFeaturesWithinGroupsForUser;
		END		
		GO
		/*
			Create vwSystemFeaturesWithinGroupsForUser
		*/
		CREATE VIEW vwSystemFeaturesWithinGroupsForUser
		AS	
			SELECT DISTINCT
				OU.OrganisationId							AS OrganisationId
				, O.[Name]									AS OrganisationName
				, U.Id										AS UserId
				, SFG.Id									AS SystemFeatureGroupId
				, SFG.[Name]								AS SystemFeatureGroupName
				, SFG.Title									AS SystemFeatureGroupTitle
				, SFG.[Description]							AS SystemFeatureGroupDescription
				, SFG.SystemAdministratorOnly				AS SystemFeatureGroupSystemAdministratorOnly
				, SFG.OrganisationAdministratorOnly			AS SystemFeatureGroupOrganisationAdministratorOnly
				, SFG.[Disabled]							AS SystemFeatureGroupDisabled
				, SFI.Id									AS SystemFeatureId
				, SFI.[Name]								AS SystemFeatureName
				, SFI.Title									AS SystemFeatureTitle
				, SFI.[Description]							AS SystemFeatureDescription
				, SFI.[Disabled]							AS SystemFeatureDisabled
				, dbo.udfGetSystemFeatureNotesForUser(SFI.Id, U.Id, OU.OrganisationId)	AS SystemFeatureNotes
			FROM [dbo].[User] U
			LEFT JOIN [dbo].[OrganisationUser] OU ON OU.UserId = U.Id
			LEFT JOIN [dbo].[Organisation] O ON O.Id = OU.OrganisationId
			LEFT JOIN [dbo].[SystemFeatureGroup] SFG ON ISNULL(SFG.[Disabled],'False') = 'False'
			LEFT JOIN [dbo].[SystemFeatureGroupItem] SFGI ON SFGI.SystemFeatureGroupId = SFG.Id
			LEFT JOIN [dbo].[SystemFeatureItem] SFI ON SFI.Id = SFGI.SystemFeatureItemId
			;
		GO
		/*********************************************************************************************************************/
		