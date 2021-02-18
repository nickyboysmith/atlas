

DECLARE @TrainerId INT;
DECLARE @VenueId INT;
DECLARE @id INT = 0;

--UPDATE [Location]
--SET PostCode = 'TW8 9DF'
--WHERE PostCode IS NULL;

IF OBJECT_ID('tempdb..#TVIDS', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TVIDS;
END

SELECT DISTINCT TV.Id
INTO #TVIDS
FROM dbo.TrainerVenue TV
INNER JOIN VenueAddress VA ON VA.VenueId = TV.VenueId
INNER JOIN [Location] L ON L.Id = VA.LocationId
INNER JOIN TrainerLocation TL ON TL.TrainerId =TV.TrainerId
INNER JOIN [Location] L2 ON L2.Id = TL.LocationId
WHERE LEN(L.PostCode) > 0
AND LEN(L2.PostCode) > 0
--AND ISNULL(TV.DistanceHomeToVenueInMiles, -1) <= 0;

WHILE EXISTS (SELECT * FROM #TVIDS) 
BEGIN 
        SELECT TOP(1) @VenueId = TV.VenueId 
			, @TrainerId = TV.TrainerId
			, @id = TVIDS.Id
		FROM #TVIDS TVIDS
        INNER JOIN dbo.TrainerVenue TV ON TVIDS.Id = TV.Id

		--PRINT @id;
        EXEC uspUpdateTrainerVenueDistance @TrainerId, @VenueId; 

		DELETE FROM #TVIDS WHERE Id = @id;
END

