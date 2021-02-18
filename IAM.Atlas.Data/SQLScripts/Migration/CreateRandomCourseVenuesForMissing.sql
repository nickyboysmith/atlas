
-- Create Random Course Venues for Missing

/*
SELECT COUNT(*)
FROM Course C
LEFT JOIN CourseVenue CV ON CV.CourseId = C.Id
WHERE CV.Id IS NULL


SELECT O.Id, V.Id AS VenueId, V.Description
FROM Organisation O
INNER JOIN Venue V ON V.OrganisationId = O.Id
WHERE V.ID IN (
			SELECT TOP 1 V2.Id
			FROM Organisation O2
			INNER JOIN Venue V2 ON V2.OrganisationId = O2.Id
			WHERE O2.Id = O.Id
			--SELECT TOP 1 Id
			--FROM (
			--	SELECT V2.Id, ROW_NUMBER() OVER (ORDER BY O2.Id, V2.Id ASC) AS RowNum
			--	FROM Organisation O2
			--	INNER JOIN Venue V2 ON V2.OrganisationId = O2.Id
			--	WHERE O2.Id = O.Id
			--	) T
			--WHERE T.RowNum = 2 --(ABS(Checksum(NewID()) % 3) + 1)
			) 
ORDER BY O.Id, V.Id
--*/

INSERT INTO CourseVenue (CourseId, VenueId, MaximumPlaces, ReservedPlaces)
SELECT 
	C.Id			AS CourseId
	, NewCV.VenueId AS VenueId
	, 0				AS MaximumPlaces
	, 0				AS ReservedPlaces
FROM Course C
INNER JOIN (
			SELECT O.Id AS OrganisationId, V.Id AS VenueId, V.Description
			FROM Organisation O
			INNER JOIN Venue V ON V.OrganisationId = O.Id
			WHERE V.ID IN (
						SELECT TOP 1 V2.Id
						FROM Organisation O2
						INNER JOIN Venue V2 ON V2.OrganisationId = O2.Id
						WHERE O2.Id = O.Id
						) 
			--ORDER BY O.Id, V.Id
			) NewCV ON NewCV.OrganisationId = C.OrganisationId
INNER JOIN Venue V ON V.Id = NewCV.VenueId
LEFT JOIN CourseVenue CV ON CV.CourseId = C.Id
WHERE CV.Id IS NULL