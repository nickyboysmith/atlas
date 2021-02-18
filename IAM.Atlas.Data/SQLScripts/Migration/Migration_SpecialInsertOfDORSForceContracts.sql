
INSERT INTO [dbo].[OrganisationDORSForceContract] (OrganisationId, DORSForceContractId)
SELECT DISTINCT 
	O.Id AS OrganisationId
	, DFC.Id AS [DORSForceContractId]
FROM (
	SELECT 'Cheshire Constabulary' AS OrgName , 53 AS FCID
	UNION SELECT 'Cheshire West and Chester Council' AS OrgName , 53 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 64 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 189 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 63 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 104 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 299 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 300 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 346 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 343 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 345 AS FCID
	UNION SELECT 'Cleveland Driver Improvement Group' AS OrgName , 344 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 299 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 300 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 104 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 63 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 63 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 189 AS FCID
	UNION SELECT 'Cleveland Police' AS OrgName , 64 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 227 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 228 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 87 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 73 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 286 AS FCID
	UNION SELECT 'DriveSafe' AS OrgName , 378 AS FCID
	UNION SELECT 'Durham Police' AS OrgName , 346 AS FCID
	UNION SELECT 'Durham Police' AS OrgName , 343 AS FCID
	UNION SELECT 'Durham Police' AS OrgName , 344 AS FCID
	UNION SELECT 'Durham Police' AS OrgName , 345 AS FCID
	UNION SELECT 'East Sussex County Council' AS OrgName , 65 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 166 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 44 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 268 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 185 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 45 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 379 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 278 AS FCID
	UNION SELECT 'Essex County Council' AS OrgName , 308 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 308 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 278 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 379 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 45 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 185 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 268 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 44 AS FCID
	UNION SELECT 'Essex Police' AS OrgName , 166 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 228 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 227 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 73 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 87 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 378 AS FCID
	UNION SELECT 'Greater Manchester Police' AS OrgName , 286 AS FCID
	UNION SELECT 'Hartlepool Borough Council' AS OrgName , 104 AS FCID
	UNION SELECT 'Merseyside Police' AS OrgName , 76 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 90 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 43 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 196 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 334 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 336 AS FCID
	UNION SELECT 'Norfolk Constabulary' AS OrgName , 335 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 335 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 336 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 334 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 196 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 43 AS FCID
	UNION SELECT 'Norfolk County Council' AS OrgName , 90 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 43 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 63 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 104 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 87 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 112 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 90 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 54 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 23 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 45 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 65 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 55 AS FCID
	UNION SELECT 'Prodrive' AS OrgName , 61 AS FCID
	UNION SELECT 'South Wales Police' AS OrgName , 23 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 54 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 69 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 112 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 55 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 205 AS FCID
	UNION SELECT 'Staffordshire County Council (a)' AS OrgName , 373 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 373 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 205 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 55 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 112 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 69 AS FCID
	UNION SELECT 'Staffordshire Police' AS OrgName , 54 AS FCID
	UNION SELECT 'Stockton-on-Tees Borough Council' AS OrgName , 64 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 122 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 187 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 61 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 263 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 374 AS FCID
	UNION SELECT 'Sussex County Council' AS OrgName , 261 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 261 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 374 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 263 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 187 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 61 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 65 AS FCID
	UNION SELECT 'Sussex Police' AS OrgName , 122 AS FCID
	UNION SELECT 'Sussex Safer Roads Partnership' AS OrgName , 187 AS FCID
	) T
INNER JOIN Organisation O ON O.[Name] = T.OrgName
INNER JOIN [dbo].[DORSForceContract] DFC ON DFC.DORSForceContractIdentifier = T.FCID
LEFT JOIN [dbo].[OrganisationDORSForceContract] ODFC ON ODFC.OrganisationId = O.Id
														AND ODFC.DORSForceContractId = DFC.Id
WHERE ODFC.Id IS NULL