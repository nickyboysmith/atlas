

SELECT TOP (1000) A.*, B.*, C.*
  FROM [dbo].[ClientPreviousId] A
  LEFT JOIN dbo.ReferringAuthorityClient B ON B.ClientId = A.ClientId
  LEFT JOIN migration.tbl_LU_Organisation C ON C.org_id = A.PreviousReferrerOrgId
  where A.ClientId = 52058 

  SELECT DISTINCT RAC.*
  FROM (
	  SELECT DISTINCT ClientId
	  FROM dbo.ReferringAuthorityClient
	  WHERE ReferringAuthorityId IS NULL
	  ) T
  INNER JOIN (
	  SELECT DISTINCT ClientId, COUNT(*) CNT
	  FROM dbo.ReferringAuthorityClient
	  GROUP BY ClientId
	  HAVING COUNT(*) > 1
	  ) T2 ON T2.ClientId = T.ClientId
	INNER JOIN dbo.ReferringAuthorityClient RAC ON RAC.ClientId = T.ClientId
  WHERE RAC.ReferringAuthorityId IS NULL
  ORDER BY RAC.ClientId

  --DELETE dbo.ReferringAuthorityClient WHERE Id IN (68351,68349,68350)

 -- DELETE RAC --Delete Duplicates with Nulls
 -- FROM (
	--  SELECT DISTINCT ClientId
	--  FROM dbo.ReferringAuthorityClient
	--  WHERE ReferringAuthorityId IS NULL
	--  ) T
 -- INNER JOIN (
	--  SELECT DISTINCT ClientId, COUNT(*) CNT
	--  FROM dbo.ReferringAuthorityClient
	--  GROUP BY ClientId
	--  HAVING COUNT(*) > 1
	--  ) T2 ON T2.ClientId = T.ClientId
	--INNER JOIN dbo.ReferringAuthorityClient RAC ON RAC.ClientId = T.ClientId
 -- WHERE RAC.ReferringAuthorityId IS NULL

 ----Insert Missing
 --INSERT INTO dbo.ReferringAuthorityClient (ReferringAuthorityId, ClientId)
 --SELECT DISTINCT CDD.ReferringAuthorityId, CDD.ClientId
 --FROM ClientDORSData CDD
 --LEFT JOIN dbo.ReferringAuthorityClient RAC ON RAC.ReferringAuthorityId = CDD.ReferringAuthorityId AND RAC.ClientId = CDD.ClientId
 --WHERE RAC.Id IS NULL
 --AND CDD.ReferringAuthorityId IS NOT NULL

  SELECT DISTINCT ClientId
  FROM dbo.ReferringAuthorityClient
  WHERE ReferringAuthorityId IS NULL

--  SELECT * 
--  FROM Organisation A
--  WHERE A.Name LIKE '%West Mercia Police%'



--  SELECT OldO.org_id, OldO.org_name, OldO.org_dors_for_id, O.Id AS NewOrgId, RA.Id NewRefAuthId, RA.DORSForceId, RA.[Name] AS RaName, RA2.[Name] AS Ra2Name
--  FROM migration.tbl_LU_Organisation OldO
--  LEFT JOIN dbo.Organisation O ON O.[Name] = OldO.org_name
--  LEFT JOIN dbo.ReferringAuthority RA ON RA.[AssociatedOrganisationId] = O.Id
--  LEFT JOIN dbo.ReferringAuthority RA2 ON RA2.[Name] = OldO.org_name
--  WHERE OldO.org_dors_for_id IS NOT NULL
--  AND RA.Id IS NULL
--  AND RA.DORSForceId IS NULL

  SELECT CDD.ClientId, OldO.org_name, OldO.org_dors_for_id, RA.[Name]
  FROM [dbo].[ClientDORSData] CDD
  INNER JOIN [dbo].[ClientPreviousId] CPI ON CPI.ClientId = CDD.ClientId
  LEFT JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = CPI.PreviousReferrerOrgId
  LEFT JOIN dbo.ReferringAuthority RA ON RA.DORSForceId = OldO.org_dors_for_id
  WHERE CDD.ReferringAuthorityId IS NULL
  ORDER BY CDD.ClientId

  --UPDATE CDD
  --SET CDD.ReferringAuthorityId = RA.Id
  --FROM [dbo].[ClientDORSData] CDD
  --INNER JOIN [dbo].[ClientPreviousId] CPI ON CPI.ClientId = CDD.ClientId
  --INNER JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = CPI.PreviousReferrerOrgId
  --INNER JOIN dbo.ReferringAuthority RA ON RA.DORSForceId = OldO.org_dors_for_id
  --WHERE CDD.ReferringAuthorityId IS NULL

  SELECT OldO.org_name, OldO.org_dors_for_id, RA.[Name]
  FROM migration.tbl_LU_Organisation OldO
  LEFT JOIN dbo.ReferringAuthority RA ON RA.DORSForceId = OldO.org_dors_for_id
  WHERE OldO.org_dors_for_id IS NOT NULL
  ORDER BY OldO.org_name

SELECT CDD.* 
FROM (SELECT ClientId, DORSAttendanceRef, COUNT(*) CNT
	FROM [dbo].[ClientDORSData]
	GROUP BY ClientId, DORSAttendanceRef
	HAVING COUNT(*) > 1
	) T
INNER JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = T.ClientId AND CDD.DORSAttendanceRef = T.DORSAttendanceRef
ORDER BY CDD.ClientId
WHERE ReferringAuthorityId IS NULL

--Find Duplicates
SELECT CDD.* 
FROM (SELECT ClientId, DORSAttendanceRef, COUNT(*) CNT
	FROM [dbo].[ClientDORSData]
	GROUP BY ClientId, DORSAttendanceRef
	HAVING COUNT(*) > 1
	) T
INNER JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = T.ClientId AND CDD.DORSAttendanceRef = T.DORSAttendanceRef
--WHERE CDD.DataValidatedAgainstDORS = 'False'
ORDER BY CDD.ClientId

----DELETE CDD
----FROM (SELECT ClientId, DORSAttendanceRef, COUNT(*) CNT
----	FROM [dbo].[ClientDORSData]
----	GROUP BY ClientId, DORSAttendanceRef
----	HAVING COUNT(*) > 1
----	) T
----INNER JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = T.ClientId AND CDD.DORSAttendanceRef = T.DORSAttendanceRef
----WHERE CDD.DataValidatedAgainstDORS = 'False'

--SELECT *
--FROM vwClientHistory WHERE ClientId = 51596  
