


SELECT OU.OrganisationId, SAU.UserId, U.LoginId, U.Name
FROM OrganisationUser OU
INNER JOIN SystemAdminUser SAU ON SAU.UserId = OU.UserId
INNER JOIN [User] U ON U.Id = OU.UserId

DELETE OU
FROM OrganisationUser OU
INNER JOIN SystemAdminUser SAU ON SAU.UserId = OU.UserId
INNER JOIN [User] U ON U.Id = OU.UserId


SELECT OU.OrganisationId, SAU.UserId, U.LoginId, U.Name
FROM OrganisationUser OU
INNER JOIN SystemAdminUser SAU ON SAU.UserId = OU.UserId
INNER JOIN [User] U ON U.Id = OU.UserId