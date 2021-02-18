

--EXEC uspCreateMigrationConnectionToOldAtlasDB
--EXEC uspDropMigrationExternalTables
--EXEC uspCreateMigrationExternalTables
--EXEC uspDropMigrationConnectionToOldAtlasDB


INSERT INTO [dbo].[DORSConnection] (LoginName, Password, OrganisationId, Enabled, PasswordLastChanged, NotificationEmail, UpdatedByUserId, LastNotificationSent, DORSStateId)
SELECT OldDL.[lg_username] AS LoginName
	, OldDL.[lg_password] AS Password
	, NewOrg.Id AS OrganisationId
	, OldDL.[lg_disable_dors] AS Enabled
	, OldDL.[lg_lastDateChanged] AS PasswordLastChanged
	, OldDL.[lg_notificationAddress] AS NotificationEmail
	, NewU.Id AS UpdatedByUserId
	, CAST('01/01/01' AS Datetime) AS LastNotificationSent
	, NewDS.[Id] AS DORSStateId
FROM [migration].tbl_DORS_Logins OldDL
INNER JOIN [migration].tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldDL.lg_owner_org_id
INNER JOIN [dbo].Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
LEFT JOIN [dbo].[User] NewU ON NewU.LoginId = 'MigrationUser'
LEFT JOIN [dbo].[DORSState] NewDS ON NewDS.Name = 'Normal'
WHERE NOT EXISTS (SELECT * 
					FROM [dbo].[DORSConnection] DC 
					WHERE DC.[LoginName] = OldDL.lg_username
					AND DC.[OrganisationId] = NewOrg.Id)

