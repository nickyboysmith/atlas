                  

/*
	Data Migration Script :- Migrate Essential Reference Data.
	Script Name: Migration_010.001_MigrateEssentialReferenceData.sql
	Author: Robert Newnham
	Created: 06/08/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Client or Course Data has been Migrated.

*/

/*
	Old Tables Data Migrated So Far
	[tbl_LU_LicenceType] ---------> [DriverLicenceType]
*/


/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_010.001_MigrateEssentialReferenceData.sql"');

/**************************************************************************************************/
	--*Essential Reference Data
	BEGIN
		PRINT('');PRINT('*Migrate Essential Reference Data Tables');
		DECLARE @LiveMigration BIT = 'False';

		DECLARE @True bit, @False bit;
		SET @True = 'True';
		SET @False = 'False';

		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';
	END

	BEGIN		
		--INSERT INTO DriverLicenceType Table
		PRINT('');PRINT('-INSERT INTO DriverLicenceType Table');
		INSERT INTO [dbo].[DriverLicenceType] ([Name], [Disabled])
		SELECT 
			'*UNKNOWN*' AS [Name]
			, 'False'	AS [Disabled]
		UNION SELECT 
			Old_LT.[lct_TypeName] AS [Name]
			, 'False' AS [Disabled]
		FROM [migration].[tbl_LU_LicenceType] Old_LT
		LEFT JOIN [dbo].[DriverLicenceType] DLT ON DLT.[Name] = Old_LT.[lct_TypeName]
		WHERE DLT.Id IS NULL; /* IE NOT INSERTED YET */

	END
	
	BEGIN		
		--INSERT INTO Gender Table
		PRINT('');PRINT('-INSERT INTO Gender Table');
		INSERT INTO dbo.Gender([Id], [Name])
		SELECT [Id], [Name]
		FROM (
				SELECT 0 AS [Id], 'Female' AS [Name]
				UNION SELECT 1 AS [Id], 'Male' AS [Name]
				UNION SELECT 8 AS [Id], 'Not Stated' AS [Name]
				UNION SELECT 9 AS [Id], 'Unknown' AS [Name]
				) AS G2
		WHERE NOT EXISTS ( SELECT * FROM dbo.Gender G WHERE G.[Name] = G2.[Name] )
	END
	
	--POPULATE PhoneType Table
	BEGIN
		PRINT('');PRINT('*POPULATE PhoneType Table');
		-- Ensure Phone Types Required Exist		
		INSERT INTO dbo.PhoneType ([Type])
		SELECT PT.[Type]
		FROM (
			SELECT 'Work' AS Type
			UNION SELECT 'Home' AS Type
			UNION SELECT 'Mobile' AS Type
			UNION SELECT 'Fax' AS Type
			UNION SELECT 'Other' AS Type
			UNION SELECT 'Online' AS Type) PT
		WHERE PT.[Type] NOT IN ( SELECT [Type] FROM dbo.PhoneType);
	END
	
	BEGIN
		IF OBJECT_ID('tempdb..#NoteType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #NoteType;
		END

		SELECT *
		INTO #NoteType
		FROM (
			SELECT 'General' AS Title
			UNION SELECT 'Instructor' AS Title
			UNION SELECT 'Register' AS Title
			UNION SELECT 'Private' AS Title
			UNION SELECT 'Referrer' AS Title
			UNION SELECT 'Other' AS Title
			UNION SELECT 'Rejection' AS Title
			) NT;
	
		INSERT INTO [dbo].[NoteType] (Name)
		SELECT DISTINCT New_NT.Title AS Name
		FROM #NoteType New_NT
		LEFT JOIN [dbo].[NoteType] NT ON NT.Name = New_NT.Title
		WHERE NT.Id IS NULL;
		
		DELETE #NoteType
		WHERE Title IN ('Private', 'Referrer');

		INSERT INTO [dbo].[CourseNoteType] (Title)
		SELECT DISTINCT New_NT.Title
		FROM #NoteType New_NT
		LEFT JOIN [dbo].[CourseNoteType] NT ON NT.Title = New_NT.Title
		WHERE NT.Id IS NULL;

	END

	--BEGIN
	--	IF OBJECT_ID('tempdb..#Organisation', 'U') IS NOT NULL
	--	BEGIN
	--		DROP TABLE #Organisation;
	--	END

	--	SELECT [OldName] AS [OldName], [Name] AS [Name], [Title] AS [Title], GetDate() AS [CreationTime], 'True' AS [Active], 1 AS [CreatedByUserId]
	--	INTO #Organisation
	--	FROM (
	--		SELECT 'Hartlepool Borough Council' AS [OldName], 'Hartlepool Borough Council' AS [Name], 'Hartlepool County Council' AS [Title]
	--		UNION
	--		SELECT 'Essex County Council' AS [OldName], 'Essex County Council' AS [Name], 'Essex County Council' AS [Title]
	--		UNION
	--		SELECT 'Gloucestershire County Council' AS [OldName], 'Gloucestershire County Council' AS [Name], 'Gloucestershire County Council' AS [Title]
	--		UNION
	--		SELECT 'DriveSafe' AS [OldName], 'DriveSafe' AS [Name], 'DriveSafe' AS [Title]
	--		UNION
	--		SELECT 'Norfolk County Council' AS [OldName], 'Norfolk County Council' AS [Name], 'Norfolk County Council' AS [Title]
	--		UNION
	--		SELECT 'Staffordshire County Council' AS [OldName], 'Staffordshire County Council' AS [Name], 'Staffordshire County Council' AS [Title]
	--		UNION
	--		SELECT 'Sussex County Council' AS [OldName], 'Sussex County Council' AS [Name], 'Sussex County Council' AS [Title]
	--		UNION
	--		SELECT 'PDS Ltd' AS [OldName], 'IAM RoadSmart' AS [Name], 'IAM RoadSmart' AS [Title]
	--		) Orgs

	--	INSERT INTO [dbo].[Organisation] ([Name], [CreationTime], [Active], [CreatedByUserId])
	--	SELECT [Name], [CreationTime], [Active], [CreatedByUserId]
	--	FROM #Organisation Orgs
	--	WHERE NOT EXISTS ( SELECT * FROM dbo.[Organisation] O WHERE O.[Name] = Orgs.[Name] )

	--END
	
	/******************* PDS_ATLAS "dbo.tbl_LU_Organisation" Table to "Organisation" table in New Atlas ***********************/
	BEGIN
		PRINT('');PRINT('*Populate Organisation')
		INSERT INTO dbo.Organisation ([Name], CreationTime, CreatedByUserId, DateUpdated, UpdatedByUserId)
		SELECT DISTINCT 
			org_name AS [Name]
			, GETDATE() AS CreationTime
			, @MigrationUserId AS CreatedByUserId
			, GETDATE() AS DateUpdated
			, @MigrationUserId AS UpdatedByUserId
		FROM migration.tbl_LU_Organisation OldOrg
		LEFT JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
		WHERE NewOrg.[Name] IS NULL /* IE Not already on the Table */
		AND OldOrg.org_active = 'True' /* Only Bring Across Active Organisations */
		--AND OldOrg.orct_isReferrer = 'False' /* Exclude Referrers */
		AND NOT EXISTS ( SELECT * FROM dbo.[Organisation] O WHERE O.[Name] = OldOrg.org_name )
		;
	END
	/**************************************************************************************************/
	
	--*Populate Regions
	BEGIN
		PRINT('');PRINT('*Populate Regions');
		INSERT INTO dbo.Region (Name, Notes)
		SELECT DISTINCT OldR.rgn_description AS Name, OldR.rgn_description AS Notes
		FROM migration.tbl_LU_Region OldR
		WHERE NOT EXISTS (SELECT * FROM dbo.Region NewR WHERE NewR.Name = OldR.rgn_description)
	END
	
	--*Populate Areas
	--INSERT INTO dbo.Area (Name, Notes)
	--SELECT DISTINCT OldA.area_name AS Name, OldA.area_name AS Notes
	--FROM PDS_ATLAS_20150429.dbo.tbl_LU_Area OldA
	--WHERE NOT EXISTS (SELECT * FROM dbo.Area NewA WHERE NewA.Name = OldA.area_name)
	
	--*Populate Areas/OrganisationArea
	BEGIN
		PRINT('');PRINT('*Populate Areas/OrganisationArea');
		INSERT INTO dbo.Area ([Name], OrganisationId, Notes)
		SELECT DISTINCT A.area_name AS [Name], NewO.Id AS OrganisationId, A.area_name AS Notes
		FROM migration.tbl_LU_Region R
		INNER JOIN migration.tbl_LU_Area A ON A.area_id = R.rgn_area_id
		INNER JOIN migration.tbl_region_CourseType RCT ON RCT.rct_rgn_id = R.rgn_id
		INNER JOIN migration.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
		INNER JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = ORCT.orc_org_id
		INNER JOIN dbo.Organisation NewO ON NewO.[Name] = OldO.org_name
		LEFT JOIN dbo.Area New_A ON New_A.[Name] = A.area_name
								AND New_A.OrganisationId = NewO.Id
		WHERE New_A.Id IS NULL;
	END
	
	BEGIN
		PRINT('');PRINT('*Special Requirements');
		INSERT INTO [dbo].[SpecialRequirement] ([Name], [Disabled], [Description], OrganisationId, DateCreated, CreatedByUserID)
		SELECT DISTINCT 
			SpecReq AS [Name]
			, 'False' AS [Disabled]
			, SpecReq AS [Description]
			, O.Id AS OrganisationId
			, GETDATE() AS DateCreated
			, @MigrationUserId AS CreatedByUserID
		FROM (
			SELECT 'Has Difficulty Reading and Writing' AS SpecReq
			UNION SELECT 'Is Deaf' AS SpecReq
			UNION SELECT 'Wheel Chair User' AS SpecReq
			UNION SELECT 'Accompanied By a Translator' AS SpecReq
			UNION SELECT 'Accompanied By a Career' AS SpecReq
			) T
		, dbo.Organisation O
		WHERE NOT EXISTS (SELECT * 
							FROM [dbo].[SpecialRequirement] SR
							WHERE SR.[Name] = T.SpecReq
							AND SR.OrganisationId = O.Id)
	END
	
	BEGIN
		DECLARE @nowt int;

	END



	BEGIN
	
		PRINT('');PRINT('*Tidy Up')
		IF OBJECT_ID('tempdb..#Organisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #Organisation;
		END

	END



	
PRINT('');PRINT('**Completed Script: "Migration_010.001_MigrateEssentialReferenceData.sql"')
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/