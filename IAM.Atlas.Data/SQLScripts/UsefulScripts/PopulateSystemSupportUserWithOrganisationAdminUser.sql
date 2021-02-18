INSERT INTO [dbo].[SystemSupportUser]

(UserId, DateAdded, OrganisationId)

SELECT  UserId, getdate(), OrganisationId

FROM [dbo].[OrganisationAdminUser]