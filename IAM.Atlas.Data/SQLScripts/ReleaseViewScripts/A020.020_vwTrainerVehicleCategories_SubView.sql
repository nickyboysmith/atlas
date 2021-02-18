
--vwTrainerVehicleCategories_SubView
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerVehicleCategories_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerVehicleCategories_SubView;
END		
GO
/*
	Create vwTrainerVehicleCategories_SubView
*/
CREATE VIEW vwTrainerVehicleCategories_SubView
AS
	SELECT
		O.Id								AS OrganisationId
		, O.[Name]							AS OrganisationName
		, TOrg.TrainerId					AS TrainerId
		, TV.Id								AS TrainerVehicleId
		, STUFF( 
					(SELECT ','
						+ 'Category: ' + VC.[Name]
						+ CHAR(13) + CHAR(10)
					FROM [dbo].TrainerVehicleCategory TVC2
					INNER JOIN [dbo].[VehicleCategory] VC ON VC.Id = TVC2.VehicleCategoryId
					WHERE TVC2.TrainerVehicleId = TV.Id
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, '') AS Categories
		, STUFF( 
					(SELECT ','
						+ ':' + CAST(VC.Id AS VARCHAR) + ':'
						+ CHAR(13) + CHAR(10)
					FROM [dbo].TrainerVehicleCategory TVC2
					INNER JOIN [dbo].[VehicleCategory] VC ON VC.Id = TVC2.VehicleCategoryId
					WHERE TVC2.TrainerVehicleId = TV.Id
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, '') AS CategoryIds
	FROM dbo.Organisation O
	INNER JOIN dbo.TrainerOrganisation TOrg				ON TOrg.OrganisationId = O.Id
	INNER JOIN dbo.TrainerVehicle TV					ON TV.TrainerId = TOrg.TrainerId
	;

GO


/*********************************************************************************************************************/
		