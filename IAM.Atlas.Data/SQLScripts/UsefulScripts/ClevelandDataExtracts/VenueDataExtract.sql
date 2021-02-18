


SELECT DISTINCT
	V.Id							AS AtlasVenueId
	, V.Title						AS VenueName
	, DS.DORSSiteIdentifier			AS DORSSiteIdentifier
	, L.[Address]					AS VenueAddress
	, L.PostCode					AS VenuePostCode
	, VL.DefaultMaximumPlaces		AS VenueMaximumPlaces
FROM dbo.Venue V
INNER JOIN dbo.CourseVenue CV ON CV.VenueId = V.Id
INNER JOIN dbo.CourseDate CD ON CD.CourseId = CV.CourseId
LEFT JOIN dbo.DORSSiteVenue DSV ON DSV.VenueId = V.Id
LEFT JOIN dbo.DORSSite DS ON DS.Id = DSV.DORSSiteId
LEFT JOIN dbo.VenueAddress VA ON VA.VenueId = V.Id
LEFT JOIN dbo.[Location] L ON L.Id = VA.LocationId
LEFT JOIN dbo.VenueLocale VL ON VL.VenueId = V.Id AND VL.Enabled = 'True'
WHERE V.OrganisationId = 318
AND CD.DateStart > DATEADD(YEAR, -3.5, GETDATE())
