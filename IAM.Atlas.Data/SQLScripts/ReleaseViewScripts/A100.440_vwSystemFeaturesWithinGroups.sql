
		-- System Features Within Groups
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwSystemFeaturesWithinGroups', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwSystemFeaturesWithinGroups;
		END		
		GO
		/*
			Create vwSystemFeaturesWithinGroups
		*/
		CREATE VIEW vwSystemFeaturesWithinGroups
		AS				
			SELECT 
				SFG.Id									AS SystemFeatureGroupId
				, SFG.[Name]							AS SystemFeatureGroupName
				, SFG.Title								AS SystemFeatureGroupTitle
				, SFG.[Description]						AS SystemFeatureGroupDescription
				, SFG.SystemAdministratorOnly			AS SystemFeatureGroupSystemAdministratorOnly
				, SFG.OrganisationAdministratorOnly		AS SystemFeatureGroupOrganisationAdministratorOnly
				, SFG.[Disabled]						AS SystemFeatureGroupDisabled
				, SFI.Id								AS SystemFeatureId
				, SFI.[Name]							AS SystemFeatureName
				, SFI.Title								AS SystemFeatureTitle
				, SFI.[Description]						AS SystemFeatureDescription
				, SFI.[Disabled]						AS SystemFeatureDisabled
				, dbo.udfGetAllSystemFeatureNotes(SFI.Id) AS SystemFeatureNotes
			FROM [dbo].[SystemFeatureGroup] SFG
			INNER JOIN [dbo].[SystemFeatureGroupItem] SFGI ON SFGI.SystemFeatureGroupId = SFG.Id
			INNER JOIN [dbo].[SystemFeatureItem] SFI ON SFI.Id = SFGI.SystemFeatureItemId
			;
		GO
		/*********************************************************************************************************************/
		