
IF OBJECT_ID('tempdb..#NewUsers', 'U') IS NOT NULL
BEGIN
	DROP TABLE #NewUsers;
END

IF OBJECT_ID('tempdb..#NewUsers2', 'U') IS NOT NULL
BEGIN
	DROP TABLE #NewUsers2;
END

SELECT 
	LEFT(O.[Name], 3) 
		+ CAST(O.Id AS VARCHAR)
		+ 'A' 
		+ CAST(G.Id AS VARCHAR)		AS [LoginId]
	, 'atlas'						AS [Password]
	, REPLACE(REPLACE(O.[Name], '&', ''), ' ', '')
		+ ' ' + CAST(O.Id AS VARCHAR)	AS [Name]
	, 'FakeU' 
		+  CAST(O.Id AS VARCHAR)
		+ '@iamFake.com'			AS [Email]
	, 'False'						AS [Disabled]
	, GETDATE()						AS [CreationTime]
	, G.Id							AS [GenderId]
	, 'True'						AS [PasswordNeverExpires]
	, (SELECT TOP 1 Id 
		FROM LoginState 
		WHERE [Name] = 'Unknown')	AS [LoginStateId]
	, 'True'						AS [LoginNotified]
	, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
	, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
	, GETDATE()						AS [DateUpdated]
	, O.Id							AS OrganisationId
	, O.[Name]						AS OrganisationName
INTO #NewUsers
FROM Gender G
, Organisation O
			
INSERT INTO [USER] (
	[LoginId], [Password], [Name], [Email]
	, [Disabled], [CreationTime], [GenderId]
	, [PasswordNeverExpires], [LoginStateId]
	, [LoginNotified], [CreatedByUserId]
	, [UpdatedByUserId], [DateUpdated]
	)
SELECT DISTINCT
	NU.[LoginId], NU.[Password], NU.[Name], NU.[Email]
	, NU.[Disabled], NU.[CreationTime], NU.[GenderId]
	, NU.[PasswordNeverExpires], NU.[LoginStateId]
	, NU.[LoginNotified], NU.[CreatedByUserId]
	, NU.[UpdatedByUserId], NU.[DateUpdated]
FROM #NewUsers NU
LEFT JOIN [User] U ON U.LoginId = NU.LoginId
WHERE U.Id IS NULL
;

INSERT INTO dbo.OrganisationUser (OrganisationId, UserId)
SELECT NU.OrganisationId,  U.Id AS UserId
FROM #NewUsers NU
INNER JOIN [User] U ON U.LoginId = NU.LoginId
LEFT JOIN OrganisationUser OU ON OU.OrganisationId = NU.OrganisationId AND OU.UserId = U.Id
WHERE OU.Id IS NULL
;
									
INSERT INTO dbo.OrganisationAdminUser (OrganisationId, UserId)
SELECT NU.OrganisationId,  U.Id AS UserId
FROM #NewUsers NU
INNER JOIN [User] U ON U.LoginId = NU.LoginId
LEFT JOIN OrganisationUser OU ON OU.OrganisationId = NU.OrganisationId AND OU.UserId = U.Id
WHERE OU.Id IS NULL
;

SELECT 
	'X' + LEFT(O.[Name], 3) 
		+ CAST(O.Id AS VARCHAR)
		+ 'U' 
		+ CAST(G.Id AS VARCHAR)		AS [LoginId]
	, 'atlas'						AS [Password]
	, REPLACE(REPLACE(O.[Name], '&', ''), ' ', '')
		+ ' ' + CAST(O.Id AS VARCHAR)	AS [Name]
	, 'FakeX' 
		+  CAST(O.Id AS VARCHAR)
		+ '@iamFake.com'			AS [Email]
	, 'False'						AS [Disabled]
	, GETDATE()						AS [CreationTime]
	, G.Id							AS [GenderId]
	, 'True'						AS [PasswordNeverExpires]
	, (SELECT TOP 1 Id 
		FROM LoginState 
		WHERE [Name] = 'Unknown')	AS [LoginStateId]
	, 'True'						AS [LoginNotified]
	, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
	, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
	, GETDATE()						AS [DateUpdated]
	, O.Id							AS OrganisationId
	, O.[Name]						AS OrganisationName
INTO #NewUsers2
FROM Gender G
, Organisation O
			
INSERT INTO [USER] (
	[LoginId], [Password], [Name], [Email]
	, [Disabled], [CreationTime], [GenderId]
	, [PasswordNeverExpires], [LoginStateId]
	, [LoginNotified], [CreatedByUserId]
	, [UpdatedByUserId], [DateUpdated]
	)
SELECT DISTINCT
	NU.[LoginId], NU.[Password], NU.[Name], NU.[Email]
	, NU.[Disabled], NU.[CreationTime], NU.[GenderId]
	, NU.[PasswordNeverExpires], NU.[LoginStateId]
	, NU.[LoginNotified], NU.[CreatedByUserId]
	, NU.[UpdatedByUserId], NU.[DateUpdated]
FROM #NewUsers2 NU
LEFT JOIN [User] U ON U.LoginId = NU.LoginId
WHERE U.Id IS NULL
;

INSERT INTO dbo.OrganisationUser (OrganisationId, UserId)
SELECT NU.OrganisationId,  U.Id AS UserId
FROM #NewUsers2 NU
INNER JOIN [User] U ON U.LoginId = NU.LoginId
LEFT JOIN OrganisationUser OU ON OU.OrganisationId = NU.OrganisationId AND OU.UserId = U.Id
WHERE OU.Id IS NULL
;
	
	
PRINT('***************************************************************************************')
PRINT('Organisation Administrators:')
SELECT OrganisationName + ':- LoginId: ' + LoginId + '   Password: ' + Password
FROM #NewUsers
ORDER BY OrganisationName, LoginId



PRINT('***************************************************************************************')
PRINT('Organisation Users:')
SELECT OrganisationName + ':- LoginId: ' + LoginId + '   Password: ' + Password
FROM #NewUsers
ORDER BY OrganisationName, LoginId

PRINT('***************************************************************************************')