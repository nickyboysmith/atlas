

  SELECT
	U.Id				AS UserId
	, U.LoginId			AS LoginId
	, U.Password		As Password
	, U.SecurePassword
	, U.Name			AS UserName
	, U.Email			AS Email
	, O_OU.Id			AS UserOrgId
	, O_OU.Name			AS UserOrgName
	, (CASE WHEN C.Id IS NULL THEN 'False' ELSE 'True' END)			AS [Client]
	, (CASE WHEN T.Id IS NULL THEN 'False' ELSE 'True' END)			AS [Trainer]
	, T.Id															AS TrainerId
	, O_TORG.Name													AS TrainerOrganisation
	, (CASE WHEN OU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Organisation User]
	, (CASE WHEN OAU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Organisation Admin]
	, (CASE WHEN SAU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Systems Admin]
  FROM [User] U 
  LEFT JOIN Client C ON C.UserId = U.Id
  LEFT JOIN Trainer T ON T.UserId = U.Id
  LEFT JOIN OrganisationUser OU ON OU.UserId = U.Id
  LEFT JOIN Organisation O_OU ON O_OU.Id = OU.OrganisationId
  LEFT JOIN OrganisationAdminUser OAU ON OAU.UserId = U.Id
  LEFT JOIN Organisation O_OAU ON O_OAU.Id = OU.OrganisationId
  LEFT JOIN SystemAdminUser SAU ON SAU.UserId = U.Id
  LEFT JOIN TrainerOrganisation TORG ON TORG.TrainerId = T.Id
  LEFT JOIN Organisation O_TORG ON O_TORG.Id = TORG.OrganisationId
  WHERE U.LoginId = 'Davies201705'
  --WHERE T.Id IS NOT NULL
  --WHERE SAU.Id IS NOT NULL
  --WHERE OU.Id IS NOT NULL
  --AND OAU.Id IS NOT NULL

  /*
  -- Fix User Data
  --Can't Be System Admin and other Type of Users
  UPDATE C
  SET C.UserId = NULL
  FROM Client C
  INNER JOIN SystemAdminUser SAU ON SAU.UserId = C.UserId;

  UPDATE T
  SET T.UserId = NULL
  FROM Trainer T
  INNER JOIN SystemAdminUser SAU ON SAU.UserId = T.UserId;

  DELETE OU
  FROM OrganisationUser OU
  INNER JOIN SystemAdminUser SAU ON SAU.UserId = OU.UserId;
  
  DELETE OAU
  FROM OrganisationAdminUser OAU
  INNER JOIN SystemAdminUser SAU ON SAU.UserId = OAU.UserId;

  --Can't be an Organisation User and other Types of Users
  UPDATE T
  SET T.UserId = NULL
  FROM Trainer T
  INNER JOIN OrganisationUser OU ON OU.UserId = T.UserId;
  
  UPDATE C
  SET C.UserId = NULL
  FROM Client C
  INNER JOIN OrganisationUser OU ON OU.UserId = C.UserId;

  --Clients Can't be Trainers
  UPDATE T
  SET T.UserId = NULL
  FROM Trainer T
  INNER JOIN Client C ON C.UserId = C.UserId;

  --*/