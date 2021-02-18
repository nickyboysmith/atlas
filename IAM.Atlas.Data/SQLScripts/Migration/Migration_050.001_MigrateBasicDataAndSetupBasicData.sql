

/*
	Data Migration Script :- Migrate Basic Data and Setup Basic Data.
	Script Name: Migration_050.001_MigrateBasicDataAndSetupBasicData.sql
	Author: Robert Newnham
	Created: 09/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Client or Course Data has been Migrated.

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_050.001_MigrateBasicDataAndSetupBasicData.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	PRINT('');PRINT('*Migrate Basic Data and Setup Basic Tables');
	
	-- Add a Temp Column to the User Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.[User]
		ADD TempFieldPreviousUserId int NULL;
	END
	GO
	

	/******************* PDS_ATLAS "Users" Table to "User" table in New Atlas ***********************/
	
	DECLARE @LiveMigration BIT = 'True';

	DECLARE @True bit, @False bit;
	SET @True = 'True';
	SET @False = 'False';

	DECLARE @SysUserId int;
	DECLARE @MigrationUserId int
	DECLARE @UnknownUserId int;
	SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
	SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
	SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';


	BEGIN
		PRINT('');PRINT('*Populate User ' + CAST(GETDATE() AS VARCHAR))
		IF OBJECT_ID('tempdb..#OldUsers', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldUsers;
		END

		SELECT 
			U.usr_ID AS Id
			, LTRIM(RTRIM(CASE WHEN U.usr_Username = '*UNKNOWN*' OR DUPS.usr_Username IS NOT NULL
								THEN REPLACE(ISNULL(U.usr_Fullname,'Unknown'), ' ', '') + (CAST(U.usr_ID AS VARCHAR))
								ELSE U.usr_Username END)
								)	AS LoginId
			, (CASE WHEN LEN(ISNULL(U.usr_PasswordPlain,'')) > 0
					THEN U.usr_PasswordPlain
					ELSE [usr_PasswordHash]
					END )							AS [Password]
			, ISNULL(U.usr_Fullname,'Unknown')		AS [Name]
			, U.usr_email							AS Email	--, 'Fake' + (CAST (U.usr_ID AS VARCHAR)) + '@iamFakeEmail.com'			AS Email	--
			, GETDATE()								AS CreationTime
			, (CASE WHEN U.usr_Username LIKE '% [deleted]' 
					OR U.usr_Username LIKE '% (expired)'
					OR U.usr_Username LIKE '%(Expired)'
					OR U.usr_deleted = 'True'
					OR DUPS.usr_Username = '*UNKNOWN*'
					THEN CAST('TRUE' AS BIT)
					ELSE CAST('FALSE' AS BIT) 
					END)							AS [Disabled]
			, CAST((CASE WHEN DUPS.usr_Username IS NOT NULL
					THEN 'True' ELSE 'False' END)
					AS BIT)							AS DuplicateLoginId
			, CAST((CASE WHEN DUPS.usr_Username = '*UNKNOWN*'
					THEN 'True' ELSE 'False' END)
					AS BIT)							AS UnknownLoginId
		INTO #OldUsers
		FROM migration.tbl_Users U
		LEFT JOIN (		
				  SELECT ISNULL([usr_Username], '*UNKNOWN*') AS [usr_Username], COUNT(*)  AS CNT
				  FROM migration.[tbl_Users]
				  GROUP BY [usr_Username]
				  HAVING COUNT(*) > 1
					) DUPS ON DUPS.[usr_Username] = ISNULL(U.[usr_Username], '*UNKNOWN*')

		INSERT INTO dbo.[User] (LoginId, [Password], [Name], Email, CreationTime, [Disabled], LoginNotified, TempFieldPreviousUserId)
		SELECT DISTINCT
			OldUser.LoginId
			, OldUser.[Password]
			, OldUser.[Name]
			, OldUser.Email
			, OldUser.CreationTime
			, OldUser.[Disabled]
			, 'True' AS LoginNotified
			, OldUser.Id AS TempFieldPreviousUserId
		FROM #OldUsers OldUser
		LEFT JOIN dbo.[User] U ON U.LoginId = OldUser.LoginId
		WHERE U.Id IS NULL;

		INSERT INTO dbo.UserPreviousId (UserId, PreviousUserId)
		SELECT NewUser.Id AS UserId, NewUser.TempFieldPreviousUserId AS PreviousUserId
		FROM dbo.[User] NewUser
		WHERE NewUser.TempFieldPreviousUserId IS NOT NULL
		AND  NewUser.TempFieldPreviousUserId NOT IN (SELECT PreviousUserId FROM dbo.UserPreviousId)

		if (@LiveMigration = 'True')
		BEGIN
			PRINT('');PRINT('*Live Migration Update User Table')
			UPDATE U
			SET U.LoginId = OldU.LoginId
			, U.[Name] = OldU.[Name]
			, U.Email = OldU.Email
			, U.[Disabled] = OldU.[Disabled]
			FROM dbo.[User] U
			INNER JOIN dbo.UserPreviousId UPI ON UPI.UserId = U.Id
			INNER JOIN #OldUsers OldU ON OldU.Id = UPI.PreviousUserId
			WHERE U.LoginId != OldU.LoginId
			OR U.[Name] != OldU.[Name]
			OR U.Email != OldU.Email
			OR U.[Disabled] != OldU.[Disabled]
			;
		END

		--IF OBJECT_ID('tempdb..#OldUsers', 'U') IS NOT NULL
		--BEGIN
		--	DROP TABLE #OldUsers;
		--END
	END
	/**************************************************************************************************/

	/**********************POPULATE OrganisationLanguage Table****************************************************************************/
	BEGIN
		PRINT('');PRINT('*Populate OrganisationLanguage ' + CAST(GETDATE() AS VARCHAR))
		INSERT INTO [dbo].[OrganisationLanguage] (OrganisationId, LanguageId, [Disabled], [Default])
		SELECT DISTINCT O.Id AS OrganisationId
				, L.Id AS LanguageId
				, 'False' AS [Disabled]
				, (CASE WHEN L.[EnglishName] = 'English' THEN 'True' ELSE 'False' END) AS [Default]
		FROM [dbo].[Language] L
		, [dbo].[Organisation] O
		WHERE [EnglishName] IN ('English', 'Welsh')
		AND NOT EXISTS (SELECT * 
						FROM [dbo].[OrganisationLanguage] OL
						WHERE OL.OrganisationId = O.Id
						AND OL.LanguageId = L.Id)
	END
	/**************************************************************************************************/


	/******************* Update Table "OrganisationUser" in New Atlas ***********************/
	BEGIN
		PRINT('');PRINT('*Populate OrganisationUser ' + CAST(GETDATE() AS VARCHAR))
		INSERT INTO dbo.OrganisationUser (OrganisationId, UserId, CreationTime)
		SELECT DISTINCT NewOrg.Id AS OrganisationId, UPI.UserId AS UserId, GETDATE() AS CreationTime
		FROM  dbo.UserPreviousId UPI
		INNER JOIN migration.tbl_Users OldU ON OldU.usr_ID = UPI.PreviousUserId
		INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldU.usr_org_id
		INNER JOIN dbo.Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
		WHERE NOT EXISTS (SELECT * 
							FROM dbo.OrganisationUser OU
							WHERE OU.OrganisationId = NewOrg.Id
							AND OU.UserId = UPI.UserId)
	END
	/**************************************************************************************************/
		
	PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR))
		
	PRINT('');PRINT('*Tidy Up Temp Columns ' + CAST(GETDATE() AS VARCHAR));
	-- Remove the Temp Column on the User Table
	BEGIN
		ALTER TABLE dbo.[User]
		DROP COLUMN TempFieldPreviousUserId
	END

	GO
	
	--PRINT('');PRINT('*Tidy Up Remove Temp Tables ' + CAST(GETDATE() AS VARCHAR));
	--IF OBJECT_ID('tempdb..#OldUsers', 'U') IS NOT NULL
	--BEGIN
	--	DROP TABLE #OldUsers;
	--END



	
PRINT('');PRINT('**Completed Script: "Migration_050.001_MigrateBasicDataAndSetupBasicData.sql" ' + CAST(GETDATE() AS VARCHAR))
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/