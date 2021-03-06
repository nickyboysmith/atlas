/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
		C.[Id]
      ,C.[Title]
      ,C.[FirstName]
      ,C.[Surname]
      ,C.[OtherNames]
      ,C.[DisplayName]
	  , U.LoginId
	  , U.Password
	  , U.Name
	  , U.Email
	  , CO.OrganisationId
	  , (CASE WHEN SAU.Id IS NULL THEN '' ELSE 'Is Admin' END)
  FROM [dbo].[Client] C
  INNER JOIN [User] U ON U.Id = C.UserId
  INNER JOIN ClientOrganisation CO ON CO.ClientId = C.Id
  LEFT JOIN SystemAdminUser SAU ON SAU.UserId = C.UserId
  order by [DateCreated] desc