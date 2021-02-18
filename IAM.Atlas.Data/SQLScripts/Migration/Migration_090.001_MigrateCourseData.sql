

/*
	Data Migration Script :- Migrate Course Data.
	Script Name: Migration_090.001_MigrateCourseData.sql
	Author: Robert Newnham
	Created: 09/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Course Data has been Migrated.


	TO DO: 
			* Set Course Language Defaults

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_090.001_MigrateCourseData.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	-- Add a Temp Column to the Course Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Course
		ADD TempFieldPreviousCourseId int NULL;
	END
	GO
	
	-- Add a Temp Column to the Trainer Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Trainer
		ADD TempFieldPreviousTrainerId int NULL;
	END
	GO
	
	-- Add a Temp Column to the Location Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Location
		ADD TempFieldId int NULL;
	END
	GO
	
	-- Add a Temp Column to the Email Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Email
		ADD TempFieldId int NULL;
	END
	GO
	
	-- Add a Temp Column to the Note Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Note
		ADD TempFieldId int NULL;
	END
	GO
	

	PRINT('');PRINT('*****************************************************************************');
	PRINT('');PRINT('**DISABLE SOME TRIGGERS');
	DISABLE TRIGGER dbo.[TRG_VenueToInsertInToTrainerVenue_Insert] ON dbo.Venue;
	GO
/********************************************************************************************************************/

	DECLARE @LiveMigration BIT = 'True';
	DECLARE @MigrateDataFor VARCHAR(200) = 'Cleveland Driver Improvement Group';
	DECLARE @MigrateDataForRegion VARCHAR(200) = 'Cleveland';
	DECLARE @MigrateDataForOldId INT = (SELECT TOP 1 [org_id] FROM migration.[tbl_LU_Organisation] WHERE [org_name] = @MigrateDataFor);
	DECLARE @MigrateDataForOldRgnId INT = (SELECT TOP 1 rgn_id FROM migration.tbl_LU_Region WHERE [rgn_description] = @MigrateDataForRegion);
	DECLARE @MigrateDataForNewId INT = (SELECT TOP 1 Id FROM [dbo].[Organisation] WHERE [Name] = @MigrateDataFor);
	
	PRINT('');PRINT('*Migrating Data For: ' + @MigrateDataFor 
					+ ' .... OldSystemID: ' + CAST(@MigrateDataForOldId AS VARCHAR)
					+ ' .... NewSystemID: ' + CAST(@MigrateDataForNewId AS VARCHAR)
					);

	PRINT('');PRINT('*Migrate Course Data Tables ' + CAST(GETDATE() AS VARCHAR));

	DECLARE @True bit, @False bit;
	SET @True = 'True';
	SET @False = 'False';

	DECLARE @SysUserId int;
	DECLARE @MigrationUserId int
	DECLARE @UnknownUserId int;
	SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
	SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
	SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

	--*Populate CourseCategory (Formerly LU_Module) .....NB CourseCategory is now CourseTypeCategory the Script has been moved to below the Populate of CourseType
	--BEGIN
	--	PRINT('');PRINT('*Populate CourseCategory (Formerly LU_Module)');
	--	INSERT INTO dbo.CourseCategory (Name, OrganisationId)
	--	SELECT DISTINCT OMOD.mod_description AS Name, ORG.Id AS OrganisationId
	--	FROM migration.tbl_LU_Module OMOD
	--	, dbo.Organisation ORG
	--	WHERE NOT EXISTS (SELECT * FROM dbo.CourseCategory CC WHERE CC.Name = OMOD.mod_description AND CC.OrganisationId = ORG.Id)
	--END
	
	--*Populate StandardCourseType
	BEGIN
		PRINT('');PRINT('*Populate StandardCourseType ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.StandardCourseType (Title, Code, Description)
		SELECT DISTINCT ct_LongDescription AS Title, ct_Description AS Code, ct_LongDescription AS Description 
		FROM migration.tbl_LU_CourseType OldCT
		WHERE NOT EXISTS(SELECT * FROM dbo.StandardCourseType NewCT WHERE NewCT.Title = OldCT.ct_LongDescription AND NewCT.Code = OldCT.ct_Description)
	END
	
	--*Populate CourseType
	-- Changed 19th Jan 2016 ... Robert Newnham
	/*
	Id, Title, Code, Description, OrganisationId, Disabled, DORSOnly
	, DaysBeforeCourseLastBooking, MinTheoryTrainers, MinPracticalTrainers
	, MaxTheoryTrainers, MaxPracticalTrainers, MaxPlaces
	*/
	BEGIN
		PRINT('');PRINT('*Populate CourseType ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.CourseType (Title, Code, Description, OrganisationId, Disabled, DORSOnly)
		SELECT DISTINCT 
			Title
			, Code
			, Description
			, OrganisationId
			, 'False' AS Disabled
			, 'True' AS DORSOnly
		FROM (
			SELECT DISTINCT
				CT.ct_LongDescription AS Title
				, CT.ct_Description AS Code
				, CT.ct_LongDescription AS Description
				, NewO.Id As OrganisationId
				, OldO.org_name As OrganisationName
				, OMOD.[mod_description] AS DefaultTheoryPractical
			FROM migration.tbl_region_CourseType RCT
			INNER JOIN migration.tbl_LU_CourseType CT ON CT.ct_ID = RCT.rct_ct_id
			INNER JOIN migration.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
			INNER JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = ORCT.orc_org_id
			INNER JOIN dbo.Organisation NewO ON NewO.Name = OldO.org_name		
			LEFT JOIN migration.tbl_LU_Module OMOD ON OMOD.mod_id = CT.ct_default_mod_id
			UNION				
			SELECT DISTINCT
				CT.ct_LongDescription AS Title
				, CT.ct_Description AS Code
				, CT.ct_LongDescription AS Description
				, NewO.Id As OrganisationId
				, OldO.org_name As OrganisationName
				, OMOD.[mod_description] AS DefaultTheoryPractical
			FROM migration.tbl_Organisation_CourseTypes OCT
			INNER JOIN migration.tbl_LU_CourseType CT ON CT.ct_ID = OCT.orct_ct_id
			INNER JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = OCT.orct_org_id
			INNER JOIN dbo.Organisation NewO ON NewO.Name = OldO.org_name	
			LEFT JOIN migration.tbl_LU_Module OMOD ON OMOD.mod_id = CT.ct_default_mod_id
			WHERE OCT.[orct_org_id] = @MigrateDataForOldId
			) OldCT
		WHERE NOT EXISTS(SELECT * 
							FROM dbo.CourseType NewCT 
							WHERE NewCT.Title = OldCT.Title
							AND NewCT.Code = OldCT.Code
							AND NewCT.OrganisationId = OldCT.OrganisationId
							);
	END
	
	--*Populate CourseTypeCategory (Formerly LU_Module)
	-- Changed 19th Jan 2016 ... Robert Newnham
	--BEGIN
	--	PRINT('');PRINT('*Populate CourseTypeCategory (Formerly LU_Module)');
	--	INSERT INTO dbo.CourseTypeCategory (CourseTypeId, Disabled, Name)
	--	SELECT DISTINCT CT.Id AS CourseTypeId, 'False' AS Disabled, OMOD.mod_description AS Name
	--	FROM migration.tbl_LU_Module OMOD
	--	, dbo.CourseType CT
	--	WHERE NOT EXISTS (SELECT * 
	--						FROM dbo.CourseTypeCategory CTC 
	--						WHERE CTC.Name = OMOD.mod_description 
	--						AND CTC.CourseTypeId = CT.Id)
	--END
	
	--*Populate Venue
	BEGIN
		PRINT('');PRINT('*Populate Venue ' + CAST(GETDATE() AS VARCHAR));
		IF OBJECT_ID('tempdb..#Venue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #Venue;
		END
		
		PRINT('');PRINT('- Create Venue Temp Table ' + CAST(GETDATE() AS VARCHAR));
		SELECT DISTINCT
			O.org_id AS OrdId
			, O.org_name As OrganisationName
			, V.vnu_description AS VenueTitle
			, V.vnu_description AS VenueDescription
			, V.vnu_prefix AS VenuePrefix
			, V.vnu_address AS VenueAddress
			, V.vnu_postcode AS VenuePostCode
			, V.vnu_emailAddress AS VenueEmail
			, LTRIM(RTRIM(CAST(V.vnu_directions AS Varchar))) AS VenueNotes
			, CT.ct_LongDescription AS VenueCourseType
			, V.[vnu_dors_id] AS VenueDORSId
			, V.[vnu_cost_weekday] AS VenueWeekdayCost
			, V.[vnu_cost_weekend] AS VenueWeekendCost
		INTO #Venue
		FROM migration.tbl_LU_Venue V
		LEFT JOIN migration.tbl_LU_Region R ON R.rgn_id = V.vnu_rgn_ID
		LEFT JOIN migration.tbl_region_CourseType RCT ON RCT.rct_rgn_id = R.rgn_id
		LEFT JOIN migration.tbl_LU_CourseType CT ON CT.ct_ID = RCT.rct_ct_id
		LEFT JOIN migration.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
		LEFT JOIN migration.tbl_LU_Organisation O ON O.org_id = ORCT.orc_org_id
		WHERE ORCT.orc_org_id = @MigrateDataForOldId
		ORDER BY 
			O.org_name
			, V.vnu_description
			, V.vnu_prefix
			, V.vnu_address
			, V.vnu_postcode
			, V.vnu_emailAddress;

		--Save Venue Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Addresses ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Location (Address, PostCode)
			SELECT DISTINCT VenueAddress AS Address, VenuePostCode AS PostCode
			FROM #Venue V
			WHERE (LEN(V.VenueAddress) > 0 OR LEN(V.VenuePostCode) > 0)
			AND NOT EXISTS(SELECT * FROM dbo.Location NewL WHERE NewL.Address = V.VenueAddress AND NewL.PostCode = V.VenuePostCode);
		END
		
		--Save Venue Email Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Email Addresses ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Email (Address)
			SELECT DISTINCT VenueEmail AS Address
			FROM #Venue V
			WHERE (LEN(V.VenueEmail) > 0)
			AND NOT EXISTS(SELECT * FROM dbo.Email NewE WHERE NewE.Address = V.VenueEmail);
		END
		
		--Save Venues
		BEGIN
			PRINT('');PRINT('*Save Venues ' + CAST(GETDATE() AS VARCHAR));
			--INSERT INTO dbo.Venue (Title, Description, Notes, Prefix, OrganisationId)
			--SELECT DISTINCT OldV.VenueTitle AS Title
			--				, OldV.VenueDescription AS Description
			--				, OldV.VenueNotes AS Notes
			--				, OldV.VenuePrefix AS Prefix
			--				, O.Id AS OrganisationId
			--FROM #Venue OldV
			--INNER JOIN dbo.Organisation O ON O.[Name] = OldV.OrganisationName
			--WHERE NOT EXISTS (SELECT * 
			--					FROM dbo.Venue NewV 
			--					WHERE NewV.Title = OldV.VenueTitle
			--					AND NewV.OrganisationId = O.Id
			--					);
			INSERT INTO dbo.Venue (Title, Description, Notes, Prefix, OrganisationId, [Enabled], Code, DORSVenue)
			SELECT DISTINCT OldV.VenueTitle			AS Title
							, ''					AS Description
							, ''					AS Notes
							, ''					AS Prefix
							, O.Id AS OrganisationId
							, 'True'				AS [Enabled]
							, ''					AS Code
							, (CASE WHEN VenueDORSId IS NULL
									THEN 'False'
									ELSE 'True'
									END)			AS DORSVenue
			FROM #Venue OldV
			INNER JOIN dbo.Organisation O ON O.[Name] = OldV.OrganisationName
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.Venue NewV 
								WHERE NewV.Title = OldV.VenueTitle
								AND NewV.OrganisationId = O.Id
								)
			;

			--Insert and Then Update avoids Duplicate Issue.
			UPDATE V
			SET V.Description = T.Description
			, V.Notes = T.Notes
			, V.Prefix = T.Prefix
			FROM (
					SELECT DISTINCT OldV.VenueTitle AS Title
									, OldV.VenueDescription AS Description
									, OldV.VenueNotes AS Notes
									, OldV.VenuePrefix AS Prefix
									, O.Id AS OrganisationId
					FROM #Venue OldV
					INNER JOIN dbo.Organisation O ON O.[Name] = OldV.OrganisationName
					WHERE NOT EXISTS (SELECT * 
										FROM dbo.Venue NewV 
										WHERE NewV.Title = OldV.VenueTitle
										AND NewV.OrganisationId = O.Id
										)
					) T
			INNER JOIN dbo.Venue V ON V.Title = T.Title AND V.OrganisationId = T.OrganisationId
			;
		END
		
		--Save Venue Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Addresses ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.VenueAddress (VenueId, LocationId)
			SELECT DISTINCT NewV.Id AS VenueId, VAdd.Id AS LocationId
			FROM dbo.Venue NewV
			INNER JOIN dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN dbo.Location VAdd ON VAdd.Address = OldV.VenueAddress AND VAdd.PostCode = OldV.VenuePostCode
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.VenueAddress NewVAdd
								WHERE NewVAdd.VenueId = NewV.Id
								AND NewVAdd.LocationId = VAdd.Id
								);
		END
		
		--Save Venue Email
		BEGIN
			PRINT('');PRINT('*Save Venue Email ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.VenueEmail (VenueId ,EmailId, MainEmail)
			SELECT DISTINCT 
					NewV.Id AS VenueId
					, VEmail.Id AS EmailId
					, @True AS MainEmail
			FROM dbo.Venue NewV
			INNER JOIN dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN dbo.Email VEmail ON VEmail.Address = OldV.VenueEmail
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.VenueEmail NewVEmail
								WHERE NewVEmail.EmailId = VEmail.Id
								);
		END
		
		--Save Venue CourseType
		BEGIN
			PRINT('');PRINT('*Save Venue CourseType ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.VenueCourseType (VenueId, CourseTypeId)
			SELECT DISTINCT NewV.Id AS VenueId, CT.Id AS CourseTypeId
			FROM dbo.Venue NewV
			INNER JOIN dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN dbo.CourseType CT ON CT.Title = OldV.VenueCourseType AND CT.OrganisationId = NewV.OrganisationId
			AND NOT EXISTS (SELECT * 
								FROM dbo.VenueCourseType VCT
								WHERE VCT.VenueId = NewV.Id
								AND VCT.CourseTypeId = CT.Id
								);
		END
		
		--Save Venue Directions
		BEGIN
			PRINT('');PRINT('*Save Venue Directions ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.VenueDirections (VenueId, Directions)
			SELECT DISTINCT V.Id AS VenueId, V.Notes
			FROM dbo.Venue V
			WHERE LEN(V.Notes) > 0
			AND NOT EXISTS (SELECT * 
								FROM dbo.VenueDirections VD
								WHERE VD.VenueId = V.Id
								);
		END
		
		--Populate Venue Locale
		BEGIN
			PRINT('');PRINT('*Populate Venue Locale ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.VenueLocale (VenueId, Title, DefaultMaximumPlaces, DefaultReservedPlaces, Enabled)
			SELECT V.Id AS VenueId, 'Default' AS Title, 0 AS DefaultMaximumPlaces, 0 AS DefaultReservedPlaces, 'True' AS Enabled
			FROM dbo.Venue V
			WHERE NOT EXISTS (SELECT * FROM dbo.VenueLocale VL WHERE VL.VenueId = V.Id AND VL.Title = 'Default')
		END
		
		--Populate Venue Region
		BEGIN
			PRINT('');PRINT('*Populate Venue Region ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[VenueRegion] (VenueId, RegionId)
			SELECT DISTINCT V.Id AS VenueId, R.Id AS RegionId
			FROM dbo.Venue V
			INNER JOIN migration.tbl_LU_Venue V2 ON V2.vnu_description = V.Title
			INNER JOIN migration.tbl_LU_Region R2 ON R2.rgn_id = V2.vnu_rgn_ID
			INNER JOIN dbo.Region R ON R.Name = R2.rgn_description
			LEFT JOIN [dbo].[VenueRegion] VR ON VR.VenueId = V.Id
											AND VR.RegionId = R.Id
			WHERE VR.Id IS NULL;
		END
		
		--Populate DORSSiteVenue 
		BEGIN
			PRINT('');PRINT('*Populate DORSSiteVenue ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[DORSSiteVenue] (VenueId, DORSSiteId)
			SELECT DISTINCT V.Id AS VenueId, DS.Id AS DORSSiteId
			FROM dbo.Venue V
			INNER JOIN migration.tbl_LU_Venue V2 ON V2.vnu_description = V.Title
			INNER JOIN dbo.DORSSite DS ON DS.DORSSiteIdentifier = V2.vnu_dors_id
			LEFT JOIN [dbo].[DORSSiteVenue] DSV ON DSV.VenueId = V.Id
												AND DSV.DORSSiteId = DS.Id
			WHERE DSV.Id IS NULL;
		END
	END
	/**************************************************************************************************/
		
	/**************************************************************************************************/
	--POPULATE VenueCostType Table
	BEGIN
		PRINT('');PRINT('*Populate VenueCostType Table' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.VenueCostType ([Name], [Disabled], OrganisationId)
		SELECT T.[Name] AS [Name], 'False' AS [Disabled], O.Id AS OrganisationId
		FROM dbo.Organisation O
		, (
			SELECT 'Weekend' AS [Name]
			UNION SELECT 'Weekday' AS [Name]) T
		WHERE NOT EXISTS ( SELECT * 
							FROM dbo.VenueCostType VCT
							WHERE VCT.[Name] = T.[Name]
							AND VCT.OrganisationId = O.Id);
	END
	/**************************************************************************************************/
	
	/**************************************************************************************************/
	--POPULATE VenueCost Table
	BEGIN
		PRINT('');PRINT('*Populate VenueCost Table' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.VenueCost (VenueId, CostTypeId, Cost, ValidFromDate, ValidToDate)
		SELECT T.VenueId, T.CostTypeId, T.Cost, T.ValidFromDate, T.ValidToDate
		FROM (
			SELECT 
				V.Id AS VenueId
				, VCT.Id AS CostTypeId
				, ISNULL(OldV.VenueWeekdayCost,0) AS Cost
				, GETDATE() AS ValidFromDate
				, NULL AS ValidToDate
			FROM #Venue OldV
			INNER JOIN dbo.Organisation O ON O.[Name] = OldV.OrganisationName
			INNER JOIN dbo.Venue V ON V.Title = OldV.VenueTitle
									AND V.OrganisationId = O.Id
			INNER JOIN dbo.VenueCostType VCT ON VCT.OrganisationId = O.Id
											AND VCT.[Name] = 'Weekday'
			UNION SELECT 
				V.Id AS VenueId
				, VCT.Id AS CostTypeId
				, ISNULL(OldV.VenueWeekendCost,0) AS Cost
				, GETDATE() AS ValidFromDate
				, NULL AS ValidToDate
			FROM #Venue OldV
			INNER JOIN dbo.Organisation O ON O.[Name] = OldV.OrganisationName
			INNER JOIN dbo.Venue V ON V.Title = OldV.VenueTitle
									AND V.OrganisationId = O.Id
			INNER JOIN dbo.VenueCostType VCT ON VCT.OrganisationId = O.Id
											AND VCT.[Name] = 'Weekend'
			) T
		LEFT JOIN dbo.VenueCost VC ON VC.VenueId = T.VenueId
									AND VC.CostTypeId = T.CostTypeId
		WHERE VC.Id IS NULL;

	END
	/**************************************************************************************************/
	
	BEGIN
		PRINT('');PRINT('*Populate Trainers ' + CAST(GETDATE() AS VARCHAR));
		
		IF OBJECT_ID('tempdb..#OldTrainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldTrainer;
		END
		
		SELECT DISTINCT
			INS.[ins_ID]								AS Id
			, INS.[ins_name]							AS TrainerName
			, (CASE WHEN CHARINDEX(' ', INS.[ins_name]) > 0
					THEN LEFT(INS.[ins_name], CHARINDEX(' ', INS.[ins_name]) - 1)
					ELSE '' END)						AS TrainerFirstname
			, (CASE WHEN CHARINDEX(' ', INS.[ins_name]) > 0
					THEN REVERSE(LEFT(REVERSE(INS.[ins_name]), CHARINDEX(' ', REVERSE(INS.[ins_name]))-1))
					ELSE INS.[ins_name] END)			AS TrainerSurname
			, (CASE WHEN CHARINDEX(' ', INS.[ins_name]) > 0
					THEN 
						(CASE WHEN CHARINDEX(' ', INS.[ins_name], CHARINDEX(' ', INS.[ins_name]) + 1) > 0
							THEN LTRIM(RTRIM(
										SUBSTRING(INS.[ins_name]
												, CHARINDEX(' ', INS.[ins_name])
												, LEN(INS.[ins_name]) - CHARINDEX(' ', REVERSE(INS.[ins_name])) - CHARINDEX(' ', INS.[ins_name]) + 1
												)
										))
							ELSE '' END)
					ELSE '' END)						AS TrainerOtherNames
			, O.[org_name]								AS TrainerOrgName
			, O.[org_id]								AS TrainerOrgId
			, R.rgn_id									AS TrainerRgnId
			, R.[rgn_description]						AS TrainerRgnName
			, R.[rgn_area_id]							AS TrainerAreaId
			, A.[area_name]								AS TrainerAreaName
			, U.usr_ID									AS TrainerPreviousUserId
			, U.usr_Fullname							AS TrainerUserName
			, U.usr_Username							AS TrainerLoginId
		INTO #OldTrainer
		FROM [dbo].[_Migration_InstructorOrganisation] M_IO
		INNER JOIN migration.[tbl_Instructor] INS				ON INS.ins_ID = M_IO.OldTrainerId
		LEFT JOIN migration.tbl_LU_Region R						ON R.rgn_id = INS.[ins_rgn_id]
		LEFT JOIN [migration].[tbl_LU_Area] A					ON A.[area_id] = R.[rgn_area_id]
		--LEFT JOIN migration.tbl_region_CourseType RCT			ON RCT.rct_rgn_id = R.rgn_id
		--LEFT JOIN migration.tbl_Organisation_RegCrseType ORCT	ON ORCT.orc_rct_id = RCT.rct_id
		LEFT JOIN migration.tbl_LU_Organisation O				ON O.org_id = M_IO.OldOrgId
		LEFT JOIN migration.[tbl_Users] U						ON U.usr_ins_id = INS.ins_ID
		WHERE M_IO.OldOrgId = @MigrateDataForOldId
		AND INS.[ins_rgn_id] = @MigrateDataForOldRgnId
		ORDER BY INS.[ins_name]

		INSERT INTO [dbo].[Trainer] (
			Title
			, FirstName
			, Surname
			, OtherNames
			, DisplayName
			, DateOfBirth
			, Locked
			, UserId
			, GenderId
			, TempFieldPreviousTrainerId
			)
		SELECT 
			''								AS Title
			, OldT.TrainerFirstname			AS FirstName
			, OldT.TrainerSurname			AS Surname
			, OldT.TrainerOtherNames		AS OtherNames
			, OldT.TrainerName				AS DisplayName
			, OldINS.[ins_date_Birth]		AS DateOfBirth
			, 'False'						AS Locked
			, UPI.UserId					AS UserId
			, (SELECT TOP 1 Id FROM dbo.Gender 
				WHERE [Name] = 'Unknown')	AS GenderId
			, OldT.Id						AS TempFieldPreviousTrainerId
		FROM #OldTrainer OldT
		INNER JOIN migration.[tbl_Instructor] OldINS	ON OldINS.[ins_ID] = OldT.Id
		LEFT JOIN [dbo].[TrainerPreviousId] TPI			ON TPI.[PreviousTrainerId] = OldT.Id
		LEFT JOIN [dbo].[UserPreviousId] UPI			ON UPI.PreviousUserId = OldT.TrainerPreviousUserId
		WHERE TPI.Id IS NULL; --Not Already entered
		
		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerPreviousId' + CAST(GETDATE() AS VARCHAR));

		INSERT INTO [dbo].[TrainerPreviousId] (TrainerId, PreviousTrainerId, DateAdded, PreviousOrgId, PreviousRgnId)
		SELECT
			T.Id							AS TrainerId
			, T.TempFieldPreviousTrainerId	AS PreviousTrainerId
			, GETDATE()						AS DateAdded
			, OldT.TrainerOrgId				AS PreviousOrgId
			, OldT.TrainerRgnId				AS PreviousRgnId
		FROM [dbo].[Trainer] T
		INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
		LEFT JOIN [dbo].[TrainerPreviousId] TPI ON TPI.[PreviousTrainerId] = OldT.Id
		WHERE TPI.Id IS NULL; --Not Already enetered
		
		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerEmail' + CAST(GETDATE() AS VARCHAR));
		--*Save EmailAddresses
		BEGIN
			INSERT INTO dbo.Email ([Address], TempFieldId)
			SELECT DISTINCT OldINS.ins_emailAddress AS [Address], T.Id AS TempFieldId
			FROM [dbo].[Trainer] T
			INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = T.TempFieldPreviousTrainerId
			WHERE LEN(OldINS.ins_emailAddress) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.Email P 
							WHERE P.TempFieldId = T.Id
							AND P.[Address] = OldINS.ins_emailAddress
							);
						
			INSERT INTO [dbo].[TrainerEmail] (TrainerId, EmailId, MainEmail)
			SELECT DISTINCT TempFieldId AS TrainerId, E.Id AS EmailId, 'True' AS MainEmail
			FROM dbo.Email E
			INNER JOIN dbo.Trainer T ON T.Id = E.TempFieldId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.[TrainerEmail] TE 
								WHERE TE.TrainerId = E.TempFieldId
								AND TE.EmailId = E.Id
								);
		END
	
		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerInsurance' + CAST(GETDATE() AS VARCHAR));

		INSERT INTO [dbo].[TrainerInsurance] (TrainerId, RenewalDate, Verified, VerifiedByUserId, DateCreated, CreatedByUserId)
		SELECT DISTINCT 
			T.Id									AS TrainerId
			, OldINS.ins_date_Insurance				AS RenewalDate
			, (CASE WHEN OldINS.[ins_date_lastCheck] IS NOT NULL
					THEN 'True'
					ELSE 'False' END)				AS Verified
			, NULL									AS VerifiedByUserId
			, ISNULL(OldINS.ins_date_lastCheck, DATEADD(YEAR, -1, GETDATE()))				AS DateCreated
			, @MigrationUserId						AS CreatedByUserId
		FROM [dbo].[Trainer] T
		INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = T.TempFieldPreviousTrainerId
		LEFT JOIN [dbo].[TrainerInsurance] TI ON TI.TrainerId = T.Id
												AND TI.RenewalDate = OldINS.ins_date_Insurance
		WHERE T.TempFieldPreviousTrainerId IS NOT NULL
		AND TI.Id IS NULL;

		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerLicence' + CAST(GETDATE() AS VARCHAR));

		INSERT INTO [dbo].[TrainerLicence] (
			TrainerId, LicenceNumber, LicenceExpiryDate, DriverLicenceTypeId
			, LicencePhotoCardExpiryDate, LicenceCheckDue, DateCreated
			)
		SELECT
			T.Id								AS TrainerId
			, OldINS.[ins_licence_number]		AS LicenceNumber
			, NULL								AS LicenceExpiryDate
			, (SELECT TOP 1 Id FROM [dbo].[DriverLicenceType] WHERE [Name] = '*UNKNOWN*') AS DriverLicenceTypeId
			, NULL								AS LicencePhotoCardExpiryDate
			, OldINS.[ins_licence_checkDue]		AS LicenceCheckDue
			, GETDATE()							AS DateCreated
		FROM [dbo].[Trainer] T
		INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
		INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
		WHERE T.TempFieldPreviousTrainerId IS NOT NULL;

		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerLocation (Addresses)' + CAST(GETDATE() AS VARCHAR));
		BEGIN
			INSERT INTO dbo.Location ([Address], PostCode, TempFieldId)
			SELECT DISTINCT CAST(OldINS.ins_address AS VARCHAR(500)) AS [Address]
							, UPPER(CAST(OldINS.ins_postcode AS Varchar(20))) AS PostCode
							, T.Id AS TempFieldId
			FROM [dbo].[Trainer] T
			INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
			INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
			WHERE T.TempFieldPreviousTrainerId IS NOT NULL
			AND (LEN(CAST(OldINS.ins_address AS VARCHAR(500))) > 0 OR LEN(OldINS.ins_postcode) > 0 )
			AND NOT EXISTS(SELECT * 
							FROM dbo.Location P 
							WHERE P.TempFieldId = T.Id
							AND P.[Address] = CAST(OldINS.ins_address AS VARCHAR)
							AND P.PostCode = UPPER(CAST(OldINS.ins_postcode AS Varchar(20)))
							);
						
			INSERT INTO [dbo].[TrainerLocation] (TrainerId, LocationId, MainLocation)
			SELECT DISTINCT TempFieldId AS TrainerId, L.Id AS LocationId, 'True'
			FROM dbo.Location L
			INNER JOIN dbo.[Trainer] T ON T.Id = L.TempFieldId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.[TrainerLocation] TA 
								WHERE TA.TrainerId = L.TempFieldId
								AND TA.LocationId = L.Id
								);
		END

		--------------------------------------------------------------------------------------------------------------

		PRINT('');PRINT('*Populate Trainers - TrainerNote' + CAST(GETDATE() AS VARCHAR));
		BEGIN
		
			INSERT INTO dbo.Note ([Note], DateCreated, CreatedByUserId, Removed, NoteTypeId, TempFieldId)
			SELECT DISTINCT 
				OldINS.[ins_notes]					AS [Note]
				, GETDATE()							AS DateCreated
				, @MigrationUserId					AS CreatedByUserId
				, 'False'							AS Removed
				, (SELECT TOP 1 Id FROM [dbo].[NoteType] WHERE [Name] = 'General')	AS NoteTypeId
				, T.Id								AS TempFieldId
			FROM [dbo].[Trainer] T
			INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
			INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
			LEFT JOIN dbo.Note N ON N.TempFieldId = OldT.Id AND N.[Note] = OldINS.[ins_notes]
			WHERE N.Id IS NULL;

			INSERT INTO [dbo].[TrainerNote] (TrainerId, NoteId)
			SELECT T.Id AS TrainerId, N.Id AS NoteId
			FROM dbo.Note N 
			INNER JOIN [dbo].[Trainer] T ON T.Id = N.TempFieldId
			WHERE N.TempFieldId IS NOT NULL;
		END

		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerPhone' + CAST(GETDATE() AS VARCHAR));
		BEGIN
			INSERT INTO [dbo].[TrainerPhone] (TrainerId, PhoneTypeId, Number)
			SELECT DISTINCT T.TrainerId, T.PhoneTypeId, T.Number
			FROM (
				SELECT 
					T.Id AS TrainerId
					, (SELECT TOP 1 Id FROM dbo.PhoneType WHERE [Type] = 'Home') AS PhoneTypeId
					, OldINS.[ins_tel_Home] AS Number
				FROM [dbo].[Trainer] T
				INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
				INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
				WHERE LEN(ISNULL(OldINS.[ins_tel_Home],'')) > 0
				UNION SELECT 
					T.Id AS TrainerId
					, (SELECT TOP 1 Id FROM dbo.PhoneType WHERE [Type] = 'Mobile') AS PhoneTypeId
					, OldINS.ins_tel_Mobile AS Number
				FROM [dbo].[Trainer] T
				INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
				INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
				WHERE LEN(ISNULL(OldINS.ins_tel_Mobile,'')) > 0
				) T
			LEFT JOIN [dbo].[TrainerPhone] TP ON TP.TrainerId = T.TrainerId
											AND TP.PhoneTypeId = T.PhoneTypeId
											AND TP.Number = T.Number
			WHERE TP.Id IS NULL;
		END
		
		--------------------------------------------------------------------------------------------------------------
		PRINT('');PRINT('*Populate Trainers - TrainerVehicle' + CAST(GETDATE() AS VARCHAR));
		BEGIN
			INSERT INTO [dbo].[TrainerVehicle] (TrainerId, VehicleTypeId, NumberPlate, Description, DateAdded, AddedByUserId)
			SELECT 
				T.Id						AS TrainerId
				, VT.Id						AS VehicleTypeId
				, NULL						AS NumberPlate
				, OldINS.[ins_carDetails]	AS Description
				, GETDATE()					AS DateAdded
				, @MigrationUserId			AS AddedByUserId
			FROM [dbo].[Trainer] T
			INNER JOIN #OldTrainer OldT ON OldT.Id = T.TempFieldPreviousTrainerId
			INNER JOIN migration.[tbl_Instructor] OldINS ON OldINS.[ins_ID] = OldT.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldT.TrainerOrgId
			INNER JOIN dbo.Organisation O ON O.[Name] = OldOrg.[org_name]
			INNER JOIN dbo.VehicleType VT ON VT.[OrganisationId] = O.Id
											AND VT.[Name] = '*UNKNOWN*'
			LEFT JOIN [dbo].[TrainerVehicle] TV ON TV.TrainerId = T.Id
												AND TV.VehicleTypeId = VT.Id
												AND TV.Description = OldINS.[ins_carDetails]
			WHERE T.TempFieldPreviousTrainerId IS NOT NULL
			AND TV.Id IS NULL;

		END
		--------------------------------------------------------------------------------------------------------------
		--PRINT('');PRINT('*Populate Trainers - TrainerVehicleCategory' + CAST(GETDATE() AS VARCHAR));

		--INSERT INTO [dbo].[TrainerVehicleCategory] (TrainerVehicleId, VehicleCategoryId)
		
	END




	/**************************************************************************************************/
	/**************************************************************************************************/
	--*Populate Course
	BEGIN
		PRINT('');PRINT('*Populate Course ' + CAST(GETDATE() AS VARCHAR));
		
		IF OBJECT_ID('tempdb..#OldCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldCourse;
		END
		
		PRINT('');PRINT('- Create Course Temp Table ' + CAST(GETDATE() AS VARCHAR));
		SELECT DISTINCT 
			C.crs_ID AS CourseId
			, O.org_id AS OrganisationId
			, O.org_name AS OrganisationName
			, C.crs_refNo AS Reference
			, C.[crs_manualDriversOnly] AS ManualCarsOnly
			, CAST(C.crs_notes AS varchar) AS Notes
			, CAST(C.crs_notes_register AS varchar) AS NotesRegister
			, CAST(C.crs_notes_instructor AS varchar) AS NotesInstructor
			, C.crs_places As CoursePlaces
			, C.[crs_placesAuto] AS PlacesAuto
			, C.[crs_placesAutoReserved] AS ReservedPlaces
			, C.[crs_released] AS Available
			, (CASE WHEN LEN(C.crs_time_Start) > 0 
					THEN SUBSTRING(C.crs_time_Start, 1, 2) + ':' + SUBSTRING(C.crs_time_Start, 3, 2)
					ELSE '00:00' END) AS DefaultStartTime
			, (CASE WHEN LEN(C.crs_time_End) > 0 
					THEN SUBSTRING(C.crs_time_End, 1, 2) + ':' + SUBSTRING(C.crs_time_End, 3, 2)
					ELSE '00:00' END) AS DefaultEndTime
			, OldCT.ct_LongDescription AS CourseTypeTitle
			, OldV.vnu_description AS VenueTitle
			, OldV.vnu_ID AS VenueId
			, M.mod_description AS CourseCategoryName
			, C.crs_attendanceSetByInstructor AS TrainerUpdatedAttendance
			, C.crs_attendanceSet		AS SendAttendanceDORS
			, C.crs_venueEmailDate		AS DateVenuEmailed
		INTO #OldCourse
		FROM [dbo].[_Migration_CourseOrganisation] M_CO
		INNER JOIN migration.tbl_Course C							ON C.crs_ID = M_CO.OldCourseId
		INNER JOIN migration.tbl_LU_CourseType OldCT ON OldCT.ct_ID = C.crs_ct_id
		LEFT JOIN migration.tbl_LU_Module M ON M.mod_id = C.crs_mod_id
		--INNER JOIN migration.tbl_region_CourseType RCT ON RCT.rct_ct_id = C.crs_ct_id
		--												AND RCT.rct_rgn_id = C.crs_rgn_id
		--INNER JOIN migration.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
		INNER JOIN migration.tbl_LU_Organisation O ON O.org_id = M_CO.OldOrgId
		INNER JOIN migration.tbl_LU_Venue OldV ON OldV.vnu_ID = C.crs_vnu_ID
		WHERE M_CO.OldOrgId = @MigrateDataForOldId
		--AND C.crs_rgn_id = @MigrateDataForOldRgnId
		;
		/*
		Id, CourseTypeId, DefaultStartTime, DefaultEndTime
		, Available, OrganisationId, Reference, TrainersRequired
		, SendAttendanceDORS, TrainerUpdatedAttendance, ManualCarsOnly, OnlineManualCarsOnly
		, CreatedByUserId, DateUpdated, CourseTypeCategoryId, LastBookingDate, AttendanceCheckRequired
		, DateAttendanceSentToDORS, AttendanceSentToDORS, AttendanceCheckVerified
		, DORSCourse, DORSNotificationRequested, DORSNotified, DateDORSNotified
		, HasInterpreter, UpdatedByUserId, DORSNotificationReason, PracticalCourse, TheoryCourse, DateCreated
		*/
		PRINT('');PRINT('- Insert into Course Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.Course (
										CourseTypeId
										, DefaultStartTime
										, DefaultEndTime
										, Available
										, OrganisationId
										, Reference
										, TrainersRequired
										, SendAttendanceDORS
										--, CourseTypeCategoryId
										, TrainerUpdatedAttendance
										, ManualCarsOnly
										, AttendanceCheckVerified
										, CreatedByUserId
										, UpdatedByUserId
										, DateUpdated
										, PracticalCourse
										, TheoryCourse
										, DORSCourse
										, DORSNotificationRequested
										, TempFieldPreviousCourseId
										, [AttendanceCheckRequired]
										)
		SELECT DISTINCT
			NewCT.Id												AS CourseTypeId
			, OC.DefaultStartTime									AS DefaultStartTime
			, OC.DefaultEndTime										AS DefaultEndTime
			, OC.Available											AS Available
			, NewO.Id												AS OrganisationId
			, OC.Reference											AS Reference
			, 0														AS TrainersRequired			
			, OC.SendAttendanceDORS									AS SendAttendanceDORS
			--, CTC.Id AS CourseTypeCategoryId
			, OC.TrainerUpdatedAttendance							AS TrainerUpdatedAttendance
			, OC.ManualCarsOnly										AS ManualCarsOnly
			, OC.TrainerUpdatedAttendance							AS AttendanceCheckVerified
			, @MigrationUserId										AS CreatedByUserId
			, @MigrationUserId										AS UpdatedByUserId
			, GETDATE()												AS DateUpdated
			, (CASE WHEN OC.CourseCategoryName = 'Theory and Practical'
					THEN 'True' ELSE 'False' END)					AS PracticalCourse
			, (CASE WHEN OC.CourseCategoryName IN ('Theory only', 'Theory and Practical')
					THEN 'True' ELSE 'False' END)					AS TheoryCourse
			, 'True'												AS DORSCourse
			, 'False'												AS DORSNotificationRequested
			, OC.CourseId											AS TempFieldPreviousCourseId
			, 'True'												AS [AttendanceCheckRequired]
		FROM #OldCourse OC
		INNER JOIN dbo.Organisation NewO ON NewO.Name = OC.OrganisationName
		INNER JOIN dbo.CourseType NewCT ON NewCT.Title = OC.CourseTypeTitle
										AND NewCT.OrganisationId = NewO.Id
		--LEFT JOIN dbo.CourseTypeCategory CTC ON CTC.Name = OC.CourseCategoryName
		--									AND CTC.CourseTypeId = NewCT.Id
		LEFT JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = OC.CourseId
		WHERE CPI.Id IS NULL
		AND NOT EXISTS (SELECT * 
							FROM dbo.Course C
							WHERE C.CourseTypeId = NewCT.Id
							AND C.OrganisationId = NewO.Id
							AND C.Reference = OC.Reference
							--AND C.CourseTypeCategoryId = CTC.Id
							)
		ORDER BY OC.CourseId;
		
		--Populate CoursePreviousId
		BEGIN
			PRINT('');PRINT('*Populate CoursePreviousId ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.CoursePreviousId (CourseId, PreviousCourseId, [DateAdded], [PreviousOrgId])
			SELECT DISTINCT 
					C.Id AS CourseId
					, C.TempFieldPreviousCourseId AS PreviousCourseId
					, GETDATE() AS [DateAdded]
					, OC.OrganisationId AS [PreviousOrgId]
			FROM dbo.Course C
			INNER JOIN #OldCourse OC ON OC.CourseId = C.TempFieldPreviousCourseId
			WHERE C.TempFieldPreviousCourseId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM dbo.CoursePreviousId CPI 
								WHERE CPI.PreviousCourseId = C.TempFieldPreviousCourseId
								)
			;
		END
	
		BEGIN
			PRINT('');PRINT('*Populate Course Venue ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[CourseVenue] (CourseId, VenueId, MaximumPlaces, ReservedPlaces, VenueLocaleId)
			SELECT DISTINCT
				CPI.CourseId		AS CourseId
				, V.Id				AS VenueId
				, OC.CoursePlaces	AS MaximumPlaces
				, OC.ReservedPlaces	AS ReservedPlaces
				, VL.Id				AS VenueLocaleId
			FROM #OldCourse OC
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = OC.CourseId
			INNER JOIN dbo.Organisation NewO ON NewO.Name = OC.OrganisationName
			INNER JOIN dbo.Venue V ON V.Title = OC.VenueTitle
									AND V.OrganisationId = NewO.Id
			LEFT JOIN dbo.VenueLocale VL ON VL.VenueId = V.Id
			LEFT JOIN [dbo].[CourseVenue] CV ON CV.CourseId = CPI.CourseId
											AND CV.VenueId = V.Id
			WHERE CV.Id IS NULL; --Not Already Inserted
		END
		
		--Populate CourseNote
		BEGIN
			PRINT('');PRINT('*Populate CourseNote ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.CourseNote (CourseId, CourseNoteTypeId, Note, CreatedByUserId, Removed)
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, CNT.Id AS CourseNoteTypeId
				, CAST(C.crs_notes AS varchar) AS Note
				, @MigrationUserId AS CreatedByUserId
				, 'False' AS Removed
			FROM migration.tbl_Course C
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN dbo.CourseNoteType CNT ON CNT.Title = 'General'
			WHERE LEN(CAST(C.crs_notes AS varchar)) > 0
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseNote CN 
							WHERE CN.CourseId = CPI.CourseId
							AND CN.CourseNoteTypeId = CNT.Id
							AND CN.Note = CAST(C.crs_notes AS varchar)
							)
			UNION 
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, CNT.Id AS CourseNoteTypeId
				, CAST(C.crs_notes_instructor AS varchar) AS Note
				, @MigrationUserId AS CreatedByUserId
				, 'False' AS Removed
			FROM migration.tbl_Course C
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN dbo.CourseNoteType CNT ON CNT.Title = 'Instructor'
			WHERE LEN(CAST(C.crs_notes_instructor AS varchar)) > 0
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseNote CN 
							WHERE CN.CourseId = CPI.CourseId
							AND CN.CourseNoteTypeId = CNT.Id
							AND CN.Note = CAST(C.crs_notes_instructor AS varchar)
							)
			UNION 
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, CNT.Id AS CourseNoteTypeId
				, CAST(C.crs_notes_register AS varchar) AS Note
				, @MigrationUserId AS CreatedByUserId
				, 'False' AS Removed
			FROM migration.tbl_Course C
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN dbo.CourseNoteType CNT ON CNT.Title = 'Register'
			WHERE LEN(CAST(C.crs_notes_register AS varchar)) > 0
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseNote CN 
							WHERE CN.CourseId = CPI.CourseId
							AND CN.CourseNoteTypeId = CNT.Id
							AND CN.Note = CAST(C.crs_notes_register AS varchar)
							)
			;
		END
		
		--Populate CourseDates
		BEGIN
			PRINT('');PRINT('*Populate CourseDate ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.CourseDate (CourseId, DateStart, DateEnd, Available, CreatedByUserId)
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, C.crs_date_Course AS DateStart
				, (CASE WHEN C.crs_isTwoDay = 'True' 
						THEN DATEADD(d, 1, C.crs_date_Course) 
						ELSE C.crs_date_Course END) AS DateEnd
				, 'True' AS Available
				, @MigrationUserId AS CreatedByUserId
			FROM migration.tbl_Course C
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			WHERE C.crs_date_Course IS NOT NULL
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseDate CD
							WHERE CD.DateStart = C.crs_date_Course
							AND CD.CourseId = CPI.CourseId
							)
			UNION 
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, C.crs_date_Course2 AS DateStart
				, (CASE WHEN C.crs_isTwoDay = 'True' 
						THEN DATEADD(d, 1, C.crs_date_Course2) 
						ELSE C.crs_date_Course2 END) AS DateEnd
				, 'True' AS Available
				, @MigrationUserId AS CreatedByUserId
			FROM migration.tbl_Course C
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			WHERE C.crs_date_Course2 IS NOT NULL
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseDate CD
							WHERE CD.DateStart = C.crs_date_Course2
							AND CD.CourseId = CPI.CourseId
							)
			;
		END
		
		BEGIN
			PRINT('');PRINT('*Populate CourseTypeFee ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[CourseTypeFee] (
				OrganisationId
				, CourseTypeId
				, EffectiveDate
				, CourseFee
				, BookingSupplement
				, PaymentDays
				, AddedByUserId
				, DateAdded
				, Disabled
				, DisabledByUserId
				, DateDisabled
				)
			SELECT DISTINCT
				O2.Id							AS OrganisationId
				, CT2.Id						AS CourseTypeId
				, DATEADD(DAY, -30, GETDATE())	AS EffectiveDate
				, RCT.[rct_courseFee]			AS CourseFee
				, RCT.[rct_bookingSupplement]	AS BookingSupplement
				, RCT.[rct_paymentDays]			AS PaymentDays
				, @MigrationUserId				AS AddedByUserId
				, GETDATE()						AS DateAdded
				, 'False'						AS Disabled
				, NULL							AS DisabledByUserId
				, NULL							AS DateDisabled
			FROM [migration].[tbl_LU_CourseType] CT
			INNER JOIN [migration].[tbl_Region_CourseType] RCT ON RCT.[rct_ct_id] = CT.[ct_id]
			INNER JOIN [migration].tbl_Organisation_RegCrseType ORCT ON ORCT.[orc_rct_id] = RCT.[rct_id]
			INNER JOIN [migration].[tbl_LU_Organisation] O ON O.[org_id] = ORCT.[orc_org_id]
			INNER JOIN dbo.Organisation O2 ON O2.Name = O.org_name
			INNER JOIN [dbo].[CourseType] CT2 ON CT2.Title = CT.ct_LongDescription
												AND CT2.OrganisationId = O2.Id
			LEFT JOIN [dbo].[CourseTypeFee] CTF ON CTF.OrganisationId = O2.Id
												AND CTF.CourseTypeId = CT2.Id
			WHERE O.[org_id] = @MigrateDataForOldId
			AND CTF.Id IS NULL
			AND RCT.[rct_active] = 'True';
		END

		BEGIN
			PRINT('');PRINT('*Update Course. Ensure AttendanceCheckVerified Set ' + CAST(GETDATE() AS VARCHAR));
			UPDATE C
			SET C.AttendanceCheckVerified = 'True'
			, C.TrainerUpdatedAttendance = 'True'
			FROM dbo.Course C
			INNER JOIN dbo.vwCourseDates_SubView CD ON CD.CourseId = C.Id
			WHERE C.OrganisationId = @MigrateDataForNewId
			AND CD.EndDate < CAST(GETDATE())
			AND C.AttendanceCheckVerified = 'False'
			;

		END
	END 
	/**************************************************************************************************/
	
/********************************************************************************************************************/

	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));
		
		PRINT('');PRINT('*Tidy Up Temp Tables ' + CAST(GETDATE() AS VARCHAR));
		--IF OBJECT_ID('tempdb..#Venue', 'U') IS NOT NULL
		--BEGIN
		--	DROP TABLE #Venue;
		--END
		
		--IF OBJECT_ID('tempdb..#OldCourse', 'U') IS NOT NULL
		--BEGIN
		--	DROP TABLE #OldCourse;
		--END		
		
	END
	
		
	PRINT('');PRINT('*****************************************************************************');
	PRINT('');PRINT('**ENABLE DISABLED TRIGGERS');
	ENABLE TRIGGER dbo.[TRG_VenueToInsertInToTrainerVenue_Insert] ON dbo.Venue;
	GO

	PRINT('');PRINT('*Tidy Up Temp Columns ' + CAST(GETDATE() AS VARCHAR));
	
	-- Remove the Temp Column on the Course Table
	BEGIN
		ALTER TABLE dbo.Course
		DROP COLUMN TempFieldPreviousCourseId;
	END
	GO
	
	-- Remove the Temp Column on the Trainer Table
	BEGIN
		ALTER TABLE dbo.Trainer
		DROP COLUMN TempFieldPreviousTrainerId;
	END
	GO
	
	-- Remove the Temp Column on the Location Table
	BEGIN
		ALTER TABLE dbo.Location
		DROP COLUMN TempFieldId;
	END
	GO
	
	-- Remove the Temp Column on the Email Table
	BEGIN
		ALTER TABLE dbo.Email
		DROP COLUMN TempFieldId;
	END
	GO
	
	-- Remove the Temp Column on the Note Table
	BEGIN
		ALTER TABLE dbo.Note
		DROP COLUMN TempFieldId;
	END
	GO




	
PRINT('');PRINT('**Completed Script: "Migration_090.001_MigrateCourseData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/
