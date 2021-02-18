
INSERT INTO [dbo].[TrainerVehicle] (TrainerId, VehicleTypeId, NumberPlate, Description, DateAdded, AddedByUserId)
SELECT T.TrainerId, T.VehicleTypeId, T.NumberPlate, T.Description, T.DateAdded, T.AddedByUserId
FROM (
		SELECT 
			T.Id AS TrainerId
			, VT2.VehicleTypeId
			, 'TR' + RIGHT(CAST(T.Id AS VARCHAR(MAX)),2) + ' ' + CAST(T.Surname AS VARCHAR(3)) AS [NumberPlate]
			, VT3.[Description]
			, GETDATE() AS DateAdded
			, dbo.udfGetSystemUserId() AS AddedByUserId
		FROM dbo.Trainer T
		INNER JOIN dbo.TrainerOrganisation TOrg ON TOrg.TrainerId = T.Id
		INNER JOIN (SELECT VT.OrganisationId, MIN(VT.Id) AS VehicleTypeId
					FROM dbo.VehicleType VT
					GROUP BY VT.OrganisationId) VT2 ON VT2.OrganisationId = TOrg.Id
		INNER JOIN dbo.VehicleType VT3 ON VT3.Id = VT2.VehicleTypeId
		UNION
		SELECT 
			T.Id AS TrainerId
			, VT2.VehicleTypeId
			, 'TR' + RIGHT(CAST(T.Id AS VARCHAR(MAX)),2) + ' ' + CAST(T.FirstName AS VARCHAR(3)) AS [NumberPlate]
			, VT3.[Description]
			, GETDATE() AS DateAdded
			, dbo.udfGetSystemUserId() AS AddedByUserId
		FROM dbo.Trainer T
		INNER JOIN dbo.TrainerOrganisation TOrg ON TOrg.TrainerId = T.Id
INNER JOIN (SELECT VT.OrganisationId, MAX(VT.Id) AS VehicleTypeId
			FROM dbo.VehicleType VT
			GROUP BY VT.OrganisationId) VT2 ON VT2.OrganisationId = TOrg.Id
INNER JOIN dbo.VehicleType VT3 ON VT3.Id = VT2.VehicleTypeId
WHERE RIGHT(CAST(T.Id AS VARCHAR(MAX)), 1) IN ('3', '7', '9')
) T
LEFT JOIN [TrainerVehicle] TV ON TV.TrainerId = T.TrainerId AND TV.NumberPlate = T.NumberPlate
WHERE TV.Id IS NULL