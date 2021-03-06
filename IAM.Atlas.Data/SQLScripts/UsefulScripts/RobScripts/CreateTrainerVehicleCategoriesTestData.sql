

INSERT INTO [dbo].[TrainerVehicleCategory] (TrainerVehicleId, VehicleCategoryId)
SELECT DISTINCT 
	TV.Id AS TrainerVehicleId
	, VC.Id AS VehicleCategoryId
FROM [dbo].[VehicleCategory] VC
INNER JOIN dbo.TrainerOrganisation TOrg ON TOrg.OrganisationId = VC.OrganisationId
INNER JOIN [dbo].[TrainerVehicle] TV ON TV.TrainerId = TOrg.TrainerId
LEFT JOIN [dbo].[TrainerVehicleCategory] TVC ON TVC.TrainerVehicleId = TV.Id AND TVC.VehicleCategoryId = VC.Id
WHERE RIGHT(CAST(VC.Id AS VARCHAR(MAX)), 2) = RIGHT(CAST(TV.Id AS VARCHAR(MAX)), 2)
AND TVC.Id IS NULL


--SELECT TVC.*
--Too Many Delete Some
DELETE TVC
FROM [TrainerVehicleCategory] TVC
LEFT JOIN (
	SELECT  
		TrainerVehicleId
		, MIN(VehicleCategoryId) AS MinVehicleCategoryId
		, MAX(VehicleCategoryId) AS MAXVehicleCategoryId
		, AVG(VehicleCategoryId) AS AVGVehicleCategoryId
		, COUNT(*) AS CNT
	FROM [dbo].[TrainerVehicleCategory] 
	GROUP BY 
		TrainerVehicleId
	HAVING COUNT(*) > 3
) T ON T.TrainerVehicleId = TVC.TrainerVehicleId
WHERE TVC.VehicleCategoryId NOT IN (T.MinVehicleCategoryId, T.MAXVehicleCategoryId, T.AVGVehicleCategoryId)
