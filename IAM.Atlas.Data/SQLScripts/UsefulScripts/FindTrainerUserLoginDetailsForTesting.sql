SELECT TOP (1000) 
		T.[Id] AS TrainerId
      ,T.[Title]
      ,T.[FirstName]
      ,T.[Surname]
      ,T.[OtherNames]
      ,T.[DisplayName]
	  , U.Id AS USerId
	  , U.LoginId
	  , U.Password
	  , U.Name
	  , U.Email
	  , CO.OrganisationId
	  , (CASE WHEN SAU.Id IS NULL THEN '' ELSE 'Is Admin' END)
  FROM [dbo].[Trainer] T
  INNER JOIN [User] U ON U.Id = T.UserId
  INNER JOIN TrainerOrganisation CO ON CO.TrainerId = T.Id
  LEFT JOIN SystemAdminUser SAU ON SAU.UserId = T.UserId
  order by U.DateUpdated desc