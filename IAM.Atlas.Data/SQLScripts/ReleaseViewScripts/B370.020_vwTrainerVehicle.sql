
--vwTrainerVehicle
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerVehicle', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerVehicle;
END		
GO
/*
	Create vwTrainerVehicle
*/
CREATE VIEW vwTrainerVehicle
AS
	SELECT
		O.Id								AS OrganisationId
		, O.[Name]							AS OrganisationName
		, TOrg.TrainerId					AS TrainerId
		, T.DisplayName						AS TrainerName
		, T.DateOfBirth						AS TrainerDateOfBirth
		, LETL.LicenceNumber				AS TrainerLicenceNumber
		, TV.Id								AS TrainerVehicleId
		, TV.VehicleTypeId					AS VehicleTypeId
		, VT.[Name]							AS VehicleTypeName
		, VT.[Description]					AS VehicleTypeDescription
		, TV.NumberPlate					AS TrainerVehicleNumberPlate
		, TV.[Description]					AS TrainerVehicleDescription
		, TV.DateAdded						AS TrainerVehicleDateAdded
		, TV.AddedByUserId					AS TrainerVehicleAddedByUserId
		, VN.Notes							AS TrainerVehicleNotes
		, VC.Categories						AS TrainerVehicleCategories
		, VC.CategoryIds					AS TrainerVehicleCategoryIds
		, (CASE WHEN LEN(ISNULL(TV.[Description],'')) > 0
				THEN TV.[Description] + CHAR(13) + CHAR(10)
				ELSE '' END)
			+ VC.Categories					AS TrainerVehicleDescriptionWithCategories
	FROM dbo.Organisation O
	INNER JOIN dbo.TrainerOrganisation TOrg				ON TOrg.OrganisationId = O.Id
	INNER JOIN dbo.Trainer T							ON T.Id = TOrg.TrainerId
	INNER JOIN dbo.TrainerVehicle TV					ON TV.TrainerId = TOrg.TrainerId
	INNER JOIN dbo.VehicleType VT						ON VT.Id = TV.VehicleTypeId
														AND VT.OrganisationId = O.Id
	LEFT JOIN dbo.vwLatestExpiringTrainerLicence LETL	ON LETL.TrainerId = T.Id
	LEFT JOIN dbo.vwTrainerVehicleNotes_SubView VN		ON VN.OrganisationId = TOrg.OrganisationId
														AND VN.TrainerId = TOrg.TrainerId
														AND VN.TrainerVehicleId = TV.Id
	LEFT JOIN dbo.vwTrainerVehicleCategories_SubView VC	ON VC.OrganisationId = TOrg.OrganisationId
														AND VC.TrainerId = TOrg.TrainerId
														AND VC.TrainerVehicleId = TV.Id
	LEFT JOIN dbo.TrainerVehicleRemove TVR	ON TVR.TrainerVehicleId = TV.Id
	WHERE TVR.Id IS NULL;

	;

GO


/*********************************************************************************************************************/
		