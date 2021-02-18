

SELECT COUNT(*)
FROM ClientOrganisation CO
INNER JOIN CourseClient CC ON CC.ClientId = CO.ClientId
INNER JOIN Course C ON C.Id = CC.CourseId
WHERE CO.OrganisationId <> C.OrganisationId

INSERT INTO [dbo].[ClientOrganisation] (ClientId, OrganisationId, DateAdded)
SELECT DISTINCT CO.ClientId, C.OrganisationId, CO.DateAdded
FROM ClientOrganisation CO
INNER JOIN CourseClient CC ON CC.ClientId = CO.ClientId
INNER JOIN Course C ON C.Id = CC.CourseId
LEFT JOIN [dbo].[ClientOrganisation] CO2 ON CO2.ClientId = CO.ClientId AND CO2.OrganisationId = C.OrganisationId
WHERE CO.OrganisationId <> C.OrganisationId
