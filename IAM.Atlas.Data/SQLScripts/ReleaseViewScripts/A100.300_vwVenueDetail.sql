
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwVenueDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwVenueDetail;
		END		
		GO
		
		/*
			Create View vwVenueDetail
		*/
		CREATE VIEW dbo.vwVenueDetail 	
		AS
			SELECT
				V.OrganisationId				AS OrganisationId
				, V.Id							AS Id
				, V.Code						AS Code
				, V.Title						AS Title
				, V.Title
					+ (CASE WHEN ISNULL(VC.Cost, 0) > 0 THEN ' (Cost £' + (CAST(VC.Cost AS VARCHAR)) +')' ELSE '' END)
					AS ExtendedTitle
				, V.[Description]				AS [Description]
				, V.Notes						AS Notes
				, V.Prefix						AS Prefix
				, ISNULL(V.[Enabled], 'True')	AS [Enabled]
				, L.[Address]					AS [Address]
				, L.PostCode					AS PostCode
				, VC.Cost						AS Cost
				, (CASE WHEN ISNULL(VC.Cost, 0) > 0 THEN 'This Venue Cost £' + (CAST(VC.Cost AS VARCHAR))
														+ CHAR(13) + CHAR(10) + ' Cost Type: ' + ISNULL(VCT.[Name], '')
													ELSE '' END) AdditionalInformation
				, v.DORSVenue					AS DORSVenue			
			FROM [dbo].[Venue] V
			LEFT JOIN [dbo].[VenueAddress] VA ON VA.VenueId = V.Id
			LEFT JOIN [dbo].[Location] L ON L.Id = VA.LocationId
			LEFT JOIN [dbo].[VenueCost] VC ON VC.Id = (SELECT TOP 1 VC2.Id
														FROM [dbo].[VenueCost] VC2
														WHERE VC2.VenueId = V.Id
														AND GetDate() BETWEEN VC2.ValidFromDate AND VC2.ValidToDate)
			LEFT JOIN [dbo].[VenueCostType] VCT ON VCT.Id = VC.CostTypeId
	
		GO
	
		/*********************************************************************************************************************/
		