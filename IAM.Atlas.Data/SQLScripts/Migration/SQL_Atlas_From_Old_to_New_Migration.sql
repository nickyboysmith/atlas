


/*	SQL_Atlas_From_Old_to_New_Migration

	This Script will be used to create data in the New Atlas (V2.0) Database from the Old Atlas (V1) Database
	The script needs to operate over 3 Databases:
		DB 1) The Old Atlas Database - Not to be Updated. Data Copied from here.
		DB 2) The New Atlas Database - Where the data will end up
		DB 3) The Backup Database - Before the existing data in the New Database is copied over it is copied to the Backup Database.

*/

-- Add a Temp Column to the Client Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Client
	ADD TempFieldPreviousClientId int NULL;
END
GO

-- Add a Temp Column to the Course Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Course
	ADD TempFieldPreviousCourseId int NULL;
END
GO
	
-- Add a Temp Column to the Location Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Location
	ADD TempFieldId int NULL;
END
GO
	
-- Add a Temp Column to the Email Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Email
	ADD TempFieldId int NULL;
END
GO

-- Add a Temp Column to the Client Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Payment
	ADD TempFieldPreviousPaymentId int NULL;
END
GO

-- Add a Temp Column to the Note Table. This will be removed further down this Script
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Note
	ADD TempPaymentId int NULL;
END
GO

DECLARE @True bit, @False bit;
SET @True = 1;
SET @False = 0;

		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

/******************* PDS_ATLAS "Users" Table to "User" table in New Atlas ***********************/

BEGIN
	IF OBJECT_ID('tempdb..#OldUsers', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #OldUsers;
	END

	SELECT 
		U.usr_ID AS Id
		, LTRIM(RTRIM(CASE WHEN U.usr_Username LIKE '% [deleted]' OR U.usr_deleted = CAST('TRUE' as bit) THEN REPLACE(U.usr_Username, ' [deleted]', '')
				ELSE U.usr_Username END)) AS LoginId
		, U.usr_PasswordPlain As Password
		, U.usr_Fullname AS Name
		, U.usr_email AS Email
		, GETDATE() AS CreationTime
		, (CASE WHEN U.usr_Username LIKE '% [deleted]' OR U.usr_deleted = CAST('TRUE' as bit) THEN CAST('TRUE' as bit)
				ELSE CAST('FALSE' as bit) END) AS Disabled
	INTO #OldUsers
	FROM PDS_ATLAS_20150429.dbo.tbl_Users U

	INSERT INTO Atlas_Dev.dbo.[User] (LoginId, Password, Name, Email, CreationTime, Disabled)
	SELECT 
		LoginId
		, Password
		, Name
		, Email
		, CreationTime
		, Disabled
	FROM #OldUsers OldUser
	WHERE OldUser.LoginId NOT IN (SELECT LoginId FROM Atlas_Dev.dbo.[User])

	INSERT INTO Atlas_Dev.dbo.UserPreviousId (UserId, PreviousUserId)
	SELECT NewUser.Id AS UserId, OldUser.Id AS PreviousUserId
	FROM Atlas_Dev.dbo.[User] NewUser
	INNER JOIN #OldUsers OldUser ON OldUser.LoginId = NewUser.LoginId
	WHERE OldUser.Id NOT IN (SELECT PreviousUserId FROM Atlas_Dev.dbo.UserPreviousId)

	IF OBJECT_ID('tempdb..#OldUsers', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #OldUsers;
	END
END
/**************************************************************************************************/

/******************* PDS_ATLAS "dbo.tbl_LU_Organisation" Table to "Organisation" table in New Atlas ***********************/
BEGIN
	INSERT INTO Atlas_Dev.dbo.Organisation (Name, CreationTime)
	SELECT DISTINCT org_name AS Name, GETDATE() AS CreationTime
	FROM PDS_ATLAS_20150429.dbo.tbl_LU_Organisation OldOrg
	LEFT JOIN Atlas_Dev.dbo.Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
	WHERE NewOrg.Name IS NULL /* IE Not already on the Table */
	AND OldOrg.org_active = 'True' /* Only Bring Across Active Organisations */
	--AND OldOrg.orct_isReferrer = 'False' /* Exclude Referrers */
	;
END
/**************************************************************************************************/

/**********************POPULATE OrganisationLanguage Table****************************************************************************/
BEGIN
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
	INSERT INTO Atlas_Dev.dbo.OrganisationUser (OrganisationId, UserId, CreationTime)
	SELECT DISTINCT NewOrg.Id AS OrganisationId, UPI.UserId AS UserId, GETDATE() AS CreationTime
	FROM  Atlas_Dev.dbo.UserPreviousId UPI
	INNER JOIN PDS_ATLAS_20150429.dbo.tbl_Users OldU ON OldU.usr_ID = UPI.PreviousUserId
	INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldU.usr_org_id
	INNER JOIN Atlas_Dev.dbo.Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
	WHERE NOT EXISTS (SELECT * 
						FROM Atlas_Dev.dbo.OrganisationUser OU
						WHERE OU.OrganisationId = NewOrg.Id
						AND OU.UserId = UPI.UserId)
END
/**************************************************************************************************/

/******************* PDS_ATLAS "Driver" Table to "Client" table in New Atlas ***********************/
BEGIN

	/*
		--Only Required in testing
		PRINT('');PRINT('*Delete Data from Client Tables');
		TRUNCATE TABLE Atlas_Dev.dbo.ClientPreviousId;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientPhone;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientPaymentNote;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientPaymentLink;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientPayment;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientOrganisation;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientNote;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientLocation;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientLicence;
		TRUNCATE TABLE Atlas_Dev.dbo.ClientEmail;
		--TRUNCATE TABLE Atlas_Dev.dbo.Client;
		DELETE FROM Atlas_Dev.dbo.Client;
	--*/

	--Create Temp Table #OldClient
	BEGIN
		PRINT('');PRINT('*Create Temp Table #OldClient');
		IF OBJECT_ID('tempdb..#OldClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldClient;
		END

		SELECT DISTINCT 
			DR.dr_ID AS Id
			, DR.dr_Title AS Title
			, (CASE WHEN Charindex(' ', DR.dr_firstname) > 0 THEN Substring(DR.dr_firstname, 1,Charindex(' ', DR.dr_firstname) - 1) 
					ELSE DR.dr_firstname
					END
				) AS FirstName
			, DR.dr_lastname AS Surname
			, (CASE WHEN Charindex(' ', DR.dr_firstname) > 0 
					THEN Substring(DR.dr_firstname
									, Charindex(' ', DR.dr_firstname)
									, LEN(DR.dr_firstname) - Charindex(' ', DR.dr_firstname) + 1
									) 
					ELSE ''
					END
				) AS OtherNames
			, (LTRIM(RTRIM(DR.dr_firstname)) + ' ' + LTRIM(RTRIM(DR.dr_lastname))) AS DisplayName
			, DRD.drd_date_birth AS DateOfBirth
		INTO #OldClient
		FROM PDS_ATLAS_20150429.dbo.tbl_Driver DR
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_Driver_Data DRD ON DRD.drd_dr_ID = DR.dr_ID
		--So as not to Process the Same again
		LEFT JOIN Atlas_Dev.dbo.ClientPreviousId CPI ON CPI.PreviousClientId = DR.dr_ID
		WHERE CPI.Id IS NULL --ie not already processed
	END

	--POPULATE Client Table
	BEGIN
		PRINT('');PRINT('*POPULATE Client Table');
					
		INSERT INTO Atlas_Dev.dbo.Client (Title, FirstName, Surname, OtherNames, DisplayName, DateOfBirth, Locked, TempFieldPreviousClientId)
		SELECT OldClient.Title
			, OldClient.FirstName
			, OldClient.Surname
			, OldClient.OtherNames
			, OldClient.DisplayName
			, OldClient.DateOfBirth
			, CAST('FALSE' as bit) AS Locked
			, OldClient.Id AS  TempFieldPreviousClientId
		FROM #OldClient OldClient
		LEFT JOIN Atlas_Dev.dbo.Client NewClient ON NewClient.Surname = OldClient.Surname 
												AND NewClient.DateOfBirth = OldClient.DateOfBirth
		WHERE NewClient.Surname IS NULL;
		
		--INSERT INTO Atlas_Dev.dbo.ClientPreviousId (ClientId, PreviousClientId)
		--SELECT NewClient.Id AS ClientId
		--	, OldClient.Id AS PreviousClientId
		--FROM #OldClient OldClient
		--INNER JOIN Atlas_Dev.dbo.Client NewClient ON NewClient.Surname = OldClient.Surname 
		--											AND NewClient.DateOfBirth = OldClient.DateOfBirth
		--WHERE OldClient.Id NOT IN (SELECT PreviousClientId FROM Atlas_Dev.dbo.ClientPreviousId);
		INSERT INTO Atlas_Dev.dbo.ClientPreviousId (ClientId, PreviousClientId)
		SELECT NewClient.Id AS ClientId
			, NewClient.TempFieldPreviousClientId AS PreviousClientId
		FROM Atlas_Dev.dbo.Client NewClient
		WHERE NewClient.TempFieldPreviousClientId NOT IN (SELECT PreviousClientId FROM Atlas_Dev.dbo.ClientPreviousId);
		

		DECLARE @FemaleId int; SELECT TOP 1 @FemaleId = Id FROM Atlas_Dev.dbo.Gender WHERE Name = 'Female';
		DECLARE @MaleId int; SELECT TOP 1 @MaleId = Id FROM Atlas_Dev.dbo.Gender WHERE Name = 'Male';

		UPDATE Atlas_Dev.dbo.Client
		SET GenderId = @FemaleId
		WHERE Title IN ('Mrs', 'Miss', 'Ms', 'The Countess Of', 'The Countess', 'Lady', 'Countess', 'Dame', 'Queen', 'Madam', 'Madame', 'Baroness', 'Sister', 'Mrfs', 'Maid', 'Princess', 'Tsarina', 'Grand Duchess', 'Mother', 'Senora','Senorita')
		AND (GenderId IS NULL OR GenderId = 9);

		UPDATE Atlas_Dev.dbo.Client
		SET GenderId = @MaleId
		WHERE Title IN ('Mr', 'Master', 'Lord', 'Sir', 'Duke', 'Father', 'Count', 'Mister', 'Sr.', 'Vicount', 'Viscount', 'Esq', 'Baron', 'Sr', 'Qari', 'Prince', 'King', 'Earl', 'Tsar', 'Grand Duke', 'Friar', 'Monsignor', 'Monsieur', 'Herr','Senor', 'Imam', 'Sheik', 'Sheikh')
		AND (GenderId IS NULL OR GenderId = 9);

	
	END
	
	DECLARE @WorkTypeId int
			, @HomeTypeId int
			, @MobileTypeId int
			, @FaxTypeId int
			, @OtherTypeId int
			, @OnlineTypeId int
			;
	
	--SET Phone Type ID Variables
	BEGIN
		PRINT('');PRINT('*SET Phone Type ID Variables');
		SELECT @WorkTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Work';
		SELECT @HomeTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Home';
		SELECT @MobileTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Mobile';
		SELECT @FaxTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Fax';
		SELECT @OtherTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Other';
		SELECT @OnlineTypeId = Id FROM Atlas_Dev.dbo.PhoneType PT WHERE PT.[Type] = 'Online';
	END
	
	--Temp Table for Client Phone Numbers and Addresses
	BEGIN
		PRINT('');PRINT('*Create Temp Table for Client Phone Numbers and Addresses');
		IF OBJECT_ID('tempdb..#TempPhoneNumbersAndAddresses', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TempPhoneNumbersAndAddresses;
		END

		SELECT 
			NewClient.Id AS ClientId
			, LTRIM(RTRIM(CAST(ISNULL(OldClientData.drd_address,'') AS Varchar))) AS ClientAddress
			, LTRIM(RTRIM(ISNULL(OldClient.dr_postcode,''))) AS ClientPostCode
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_telHome,''))) AS ClientPhone_Home
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_telWork,''))) AS ClientPhone_Work
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_telMobile,''))) AS ClientPhone_Mobile
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_telFax,''))) AS ClientPhone_Fax
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_emailAddress,''))) AS ClientEmail
			, LTRIM(RTRIM(ISNULL(OldClientData.drd_online_contactNumber,''))) AS ClientPhone_OnlineContactNumber
		INTO #TempPhoneNumbersAndAddresses
		FROM Atlas_Dev.dbo.Client NewClient
		INNER JOIN Atlas_Dev.dbo.ClientPreviousId NewClientPrev ON NewClientPrev.ClientId = NewClient.Id
		INNER JOIN #OldClient tempTable ON tempTable.Id = NewClientPrev.PreviousClientId -- ie only the new ones just processed
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_Driver OldClient ON OldClient.dr_ID = NewClientPrev.PreviousClientId
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_Driver_Data OldClientData ON OldClientData.drd_dr_ID = NewClientPrev.PreviousClientId
		ORDER BY NewClient.Id;
	END
		
	--*Save Phone Numbers
	--Home
	BEGIN
		PRINT('');PRINT('*Save Client Home Phone Numbers');
		INSERT INTO Atlas_Dev.dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
		SELECT ClientId, @HomeTypeId AS PhoneTypeId, CAST(ClientPhone_Home AS Varchar(40)) AS PhoneNumber
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientPhone_Home) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.ClientPhone P 
						WHERE P.ClientId = ClientId
						AND P.PhoneTypeId = @HomeTypeId
						AND P.PhoneNumber = CAST(ClientPhone_Home AS Varchar(40))
						);
	END
	
	-- Work
	BEGIN
		PRINT('');PRINT('*Save Client Work Phone Numbers');
		INSERT INTO Atlas_Dev.dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
		SELECT ClientId, @WorkTypeId AS PhoneTypeId, CAST(ClientPhone_Work AS Varchar(40)) AS PhoneNumber
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientPhone_Work) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.ClientPhone P 
						WHERE P.ClientId = ClientId
						AND P.PhoneTypeId = @WorkTypeId
						AND P.PhoneNumber = CAST(ClientPhone_Work AS Varchar(40))
						);
	END

	-- Mobile
	BEGIN
		PRINT('');PRINT('*Save Client Mobile Phone Numbers');
		INSERT INTO Atlas_Dev.dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
		SELECT ClientId, @MobileTypeId AS PhoneTypeId, CAST(ClientPhone_Mobile AS Varchar(40)) AS PhoneNumber
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientPhone_Mobile) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.ClientPhone P 
						WHERE P.ClientId = ClientId
						AND P.PhoneTypeId = @MobileTypeId
						AND P.PhoneNumber = CAST(ClientPhone_Mobile AS Varchar(40))
						);				
	END
			
	-- Fax
	BEGIN
		PRINT('');PRINT('*Save Client Fax Numbers');
		INSERT INTO Atlas_Dev.dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
		SELECT ClientId, @FaxTypeId AS PhoneTypeId, CAST(ClientPhone_Fax AS Varchar(40)) AS PhoneNumber
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientPhone_Fax) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.ClientPhone P 
						WHERE P.ClientId = ClientId
						AND P.PhoneTypeId = @FaxTypeId
						AND P.PhoneNumber = CAST(ClientPhone_Fax AS Varchar(40))
						);
	END
	
	-- Online
	BEGIN
		PRINT('');PRINT('*Save Client Online Phone Numbers');
		INSERT INTO Atlas_Dev.dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
		SELECT ClientId, @OnlineTypeId AS PhoneTypeId, CAST(ClientPhone_OnlineContactNumber AS Varchar(40)) AS PhoneNumber
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientPhone_OnlineContactNumber) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.ClientPhone P 
						WHERE P.ClientId = ClientId
						AND P.PhoneTypeId = @OnlineTypeId
						AND P.PhoneNumber = CAST(ClientPhone_OnlineContactNumber AS Varchar(40))
						);
	END
	
	--*Save Addresses
	BEGIN
		PRINT('');PRINT('*Save Client Addresses');
		INSERT INTO Atlas_Dev.dbo.Location ([Address], PostCode, TempFieldId)
		SELECT ClientAddress AS [Address], CAST(ClientPostCode AS Varchar(20)) AS PostCode, ClientId AS TempFieldId
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientAddress) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.Location P 
						WHERE P.TempFieldId = ClientId
						AND P.[Address] = ClientAddress
						AND P.PostCode = CAST(ClientPostCode AS Varchar(20))
						);
						
		INSERT INTO Atlas_Dev.dbo.ClientLocation (ClientId, LocationId)
		SELECT TempFieldId AS ClientId, L.Id AS LocationId
		FROM Atlas_Dev.dbo.Location L
		INNER JOIN Atlas_Dev.dbo.Client C ON C.Id = L.TempFieldId
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.ClientLocation CA 
							WHERE CA.ClientId = L.TempFieldId
							AND CA.LocationId = L.Id
							);
	END
	
	--*Save EmailAddresses
	BEGIN
		PRINT('');PRINT('*Save Client Email');
		INSERT INTO Atlas_Dev.dbo.Email ([Address], TempFieldId)
		SELECT ClientEmail AS [Address], ClientId AS TempFieldId
		FROM #TempPhoneNumbersAndAddresses
		WHERE LEN(ClientEmail) > 0
		AND NOT EXISTS(SELECT * 
						FROM Atlas_Dev.dbo.Email P 
						WHERE P.TempFieldId = ClientId
						AND P.[Address] = ClientEmail
						);
						
		INSERT INTO Atlas_Dev.dbo.ClientEmail (ClientId, EmailId)
		SELECT TempFieldId AS ClientId, E.Id AS EmailId
		FROM Atlas_Dev.dbo.Email E
		INNER JOIN Atlas_Dev.dbo.Client C ON C.Id = E.TempFieldId
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.ClientEmail CE 
							WHERE CE.ClientId = E.TempFieldId
							AND CE.EmailId = E.Id
							);
	END
	
	--*Save Client Organisation
	BEGIN
		PRINT('');PRINT('*Save Client Organisation');
		INSERT INTO Atlas_Dev.dbo.ClientOrganisation (ClientId, OrganisationId)
		SELECT NewClientPrev.ClientId, NewOrg.Id AS OrganisationId
		FROM PDS_ATLAS_20150429.dbo.tbl_Driver OldDr
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldDr.dr_referrer_org_ID
		INNER JOIN Atlas_Dev.dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
		INNER JOIN Atlas_Dev.dbo.Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.ClientOrganisation CO 
							WHERE CO.ClientId = NewClientPrev.ClientId
							AND CO.OrganisationId = NewOrg.Id
							)
		;
	END

END

/********************************************************************************************************************/

	--*Populate CourseCategory (Formerly LU_Module) .....NB CourseCategory is now CourseTypeCategory the Script has been moved to below the Populate of CourseType
	--BEGIN
	--	PRINT('');PRINT('*Populate CourseCategory (Formerly LU_Module)');
	--	INSERT INTO Atlas_Dev.dbo.CourseCategory (Name, OrganisationId)
	--	SELECT DISTINCT OMOD.mod_description AS Name, ORG.Id AS OrganisationId
	--	FROM PDS_ATLAS_20150429.dbo.tbl_LU_Module OMOD
	--	, Atlas_Dev.dbo.Organisation ORG
	--	WHERE NOT EXISTS (SELECT * FROM Atlas_Dev.dbo.CourseCategory CC WHERE CC.Name = OMOD.mod_description AND CC.OrganisationId = ORG.Id)
	--END
	
	--*Populate StandardCourseType
	BEGIN
		PRINT('');PRINT('*Populate StandardCourseType');
		INSERT INTO Atlas_Dev.dbo.StandardCourseType (Title, Code, Description)
		SELECT DISTINCT ct_LongDescription AS Title, ct_Description AS Code, ct_LongDescription AS Description 
		FROM PDS_ATLAS_20150429.dbo.tbl_LU_CourseType OldCT
		WHERE NOT EXISTS(SELECT * FROM Atlas_Dev.dbo.StandardCourseType NewCT WHERE NewCT.Title = OldCT.ct_LongDescription AND NewCT.Code = OldCT.ct_Description)
	END
	
	--*Populate CourseType
	-- Changed 19th Jan 2016 ... Robert Newnham
	BEGIN
		PRINT('');PRINT('*Populate CourseType');
		INSERT INTO Atlas_Dev.dbo.CourseType (Title, Code, Description, OrganisationId, Disabled)
		SELECT DISTINCT Title, Code, Description, OrganisationId, 'False'
		FROM (
			SELECT DISTINCT
				CT.ct_LongDescription AS Title
				, CT.ct_Description AS Code
				, CT.ct_LongDescription AS Description
				, NewO.Id As OrganisationId
				, OldO.org_name As OrganisationName
			FROM PDS_ATLAS_20150429.dbo.tbl_region_CourseType RCT
			INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_CourseType CT ON CT.ct_ID = RCT.rct_ct_id
			INNER JOIN PDS_ATLAS_20150429.dbo.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
			INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation OldO ON OldO.org_id = ORCT.orc_org_id
			INNER JOIN Atlas_Dev.dbo.Organisation NewO ON NewO.Name = OldO.org_name		
			UNION				
			SELECT DISTINCT
				CT.ct_LongDescription AS Title
				, CT.ct_Description AS Code
				, CT.ct_LongDescription AS Description
				, NewO.Id As OrganisationId
				, OldO.org_name As OrganisationName
			FROM PDS_ATLAS_20150429.dbo.tbl_Organisation_CourseTypes OCT
			INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_CourseType CT ON CT.ct_ID = OCT.orct_ct_id
			INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation OldO ON OldO.org_id = OCT.orct_org_id
			INNER JOIN Atlas_Dev.dbo.Organisation NewO ON NewO.Name = OldO.org_name	
			) OldCT
		WHERE NOT EXISTS(SELECT * 
							FROM Atlas_Dev.dbo.CourseType NewCT 
							WHERE NewCT.Title = OldCT.Title
							AND NewCT.Code = OldCT.Code
							AND NewCT.OrganisationId = OldCT.OrganisationId
							);
	END
	
	--*Populate CourseTypeCategory (Formerly LU_Module)
	-- Changed 19th Jan 2016 ... Robert Newnham
	BEGIN
		PRINT('');PRINT('*Populate CourseTypeCategory (Formerly LU_Module)');
		INSERT INTO Atlas_Dev.dbo.CourseTypeCategory (CourseTypeId, Disabled, Name)
		SELECT DISTINCT CT.Id AS CourseTypeId, 'False' AS Disabled, OMOD.mod_description AS Name
		FROM PDS_ATLAS_20150429.dbo.tbl_LU_Module OMOD
		, Atlas_Dev.dbo.CourseType CT
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.CourseTypeCategory CTC 
							WHERE CTC.Name = OMOD.mod_description 
							AND CTC.CourseTypeId = CT.Id)
	END
	
	--*Populate Venue
	BEGIN
		PRINT('');PRINT('*Populate Venue');
		IF OBJECT_ID('tempdb..#Venue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #Venue;
		END
		
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
		INTO #Venue
		FROM PDS_ATLAS_20150429.dbo.tbl_LU_Venue V
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Region R ON R.rgn_id = V.vnu_rgn_ID
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_region_CourseType RCT ON RCT.rct_rgn_id = R.rgn_id
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_CourseType CT ON CT.ct_ID = RCT.rct_ct_id
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation O ON O.org_id = ORCT.orc_org_id
		ORDER BY 
			O.org_name
			, V.vnu_description
			, V.vnu_prefix
			, V.vnu_address
			, V.vnu_postcode
			, V.vnu_emailAddress;

		--Save Venue Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Addresses');
			INSERT INTO Atlas_Dev.dbo.Location (Address, PostCode)
			SELECT DISTINCT VenueAddress AS Address, VenuePostCode AS PostCode
			FROM #Venue V
			WHERE (LEN(V.VenueAddress) > 0 OR LEN(V.VenuePostCode) > 0)
			AND NOT EXISTS(SELECT * FROM Atlas_Dev.dbo.Location NewL WHERE NewL.Address = V.VenueAddress AND NewL.PostCode = V.VenuePostCode);
		END
		
		--Save Venue Email Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Email Addresses');
			INSERT INTO Atlas_Dev.dbo.Email (Address)
			SELECT DISTINCT VenueEmail AS Address
			FROM #Venue V
			WHERE (LEN(V.VenueEmail) > 0)
			AND NOT EXISTS(SELECT * FROM Atlas_Dev.dbo.Email NewE WHERE NewE.Address = V.VenueEmail);
		END
		
		--Save Venues
		BEGIN
			PRINT('');PRINT('*Save Venues');
			INSERT INTO Atlas_Dev.dbo.Venue (Title, Description, Notes, Prefix, OrganisationId)
			SELECT DISTINCT VenueTitle AS Title
							, VenueDescription AS Description
							, VenueNotes AS Notes
							, VenuePrefix AS Prefix
							, O.Id AS OrganisationId
			FROM #Venue OldV
			INNER JOIN Atlas_Dev.dbo.Organisation O ON O.Name = OldV.OrganisationName
			INNER JOIN Atlas_Dev.dbo.Location VAdd ON VAdd.Address = OldV.VenueAddress AND VAdd.PostCode = OldV.VenuePostCode
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.Venue NewV 
								WHERE NewV.Title = OldV.VenueTitle
								AND NewV.OrganisationId = O.Id
								);
		END
		
		--Save Venue Addresses
		BEGIN
			PRINT('');PRINT('*Save Venue Addresses');
			INSERT INTO Atlas_Dev.dbo.VenueAddress (VenueId, LocationId)
			SELECT DISTINCT NewV.Id AS VenueId, VAdd.Id AS LocationId
			FROM Atlas_Dev.dbo.Venue NewV
			INNER JOIN Atlas_Dev.dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN Atlas_Dev.dbo.Location VAdd ON VAdd.Address = OldV.VenueAddress AND VAdd.PostCode = OldV.VenuePostCode
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.VenueAddress NewVAdd
								WHERE NewVAdd.VenueId = NewV.Id
								AND NewVAdd.LocationId = VAdd.Id
								);
		END
		
		--Save Venue Email
		BEGIN
			PRINT('');PRINT('*Save Venue Email');
			INSERT INTO Atlas_Dev.dbo.VenueEmail (EmailId, MainEmail)
			SELECT DISTINCT VEmail.Id AS EmailId, @True AS MainEmail
			FROM Atlas_Dev.dbo.Venue NewV
			INNER JOIN Atlas_Dev.dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN Atlas_Dev.dbo.Email VEmail ON VEmail.Address = OldV.VenueEmail
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.VenueEmail NewVEmail
								WHERE NewVEmail.EmailId = VEmail.Id
								);
		END
		
		--Save Venue CourseType
		BEGIN
			PRINT('');PRINT('*Save Venue CourseType');
			INSERT INTO Atlas_Dev.dbo.VenueCourseType (VenueId, CourseTypeId)
			SELECT DISTINCT NewV.Id AS VenueId, CT.Id AS CourseTypeId
			FROM Atlas_Dev.dbo.Venue NewV
			INNER JOIN Atlas_Dev.dbo.Organisation O ON O.Id = NewV.OrganisationId
			INNER JOIN #Venue OldV ON OldV.OrganisationName = O.Name
										AND OldV.VenueTitle = NewV.Title
										AND OldV.OrganisationName = O.Name
			INNER JOIN Atlas_Dev.dbo.CourseType CT ON CT.Title = OldV.VenueCourseType AND CT.OrganisationId = NewV.OrganisationId
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.VenueCourseType VCT
								WHERE VCT.VenueId = NewV.Id
								AND VCT.CourseTypeId = CT.Id
								);
		END
		
		--Save Venue Directions
		BEGIN
			PRINT('');PRINT('*Save Venue Directions');
			INSERT INTO Atlas_Dev.dbo.VenueDirections (VenueId, Directions)
			SELECT DISTINCT V.Id AS VenueId, V.Notes
			FROM Atlas_Dev.dbo.Venue V
			WHERE LEN(V.Notes) > 0
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.VenueDirections VD
								WHERE VD.VenueId = V.Id
								);
		END
		
		--Populate Venue Locale
		--	Inserted 19th Jan 2016 ... Robert Newnham
		BEGIN
			PRINT('');PRINT('*Populate Venue Locale');
			INSERT INTO Atlas_Dev.dbo.VenueLocale (VenueId, Title, DefaultMaximumPlaces, DefaultReservedPlaces, Enabled)
			SELECT V.Id AS VenueId, 'Default' AS Title, 0 AS DefaultMaximumPlaces, 0 AS DefaultReservedPlaces, 'True' AS Enabled
			FROM Atlas_Dev.dbo.Venue V
			WHERE NOT EXISTS (SELECT * FROM Atlas_Dev.dbo.VenueLocale VL WHERE VL.VenueId = V.Id AND VL.Title = 'Default')
		END
		
		--TODO *** VENUE COST AND VENUE COST TYPE
	END
	/**************************************************************************************************/
		
	--*Populate Course
	BEGIN
		PRINT('');PRINT('*Populate Course');
		
		IF OBJECT_ID('tempdb..#OldCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldCourse;
		END
		
		SELECT DISTINCT 
			C.crs_ID AS CourseId
			, O.org_id AS OrganisationId
			, O.org_name AS OrganisationName
			, C.crs_refNo AS Reference
			, CAST(C.crs_notes AS varchar) AS Notes
			, CAST(C.crs_notes_register AS varchar) AS NotesRegister
			, CAST(C.crs_notes_instructor AS varchar) AS NotesInstructor
			, C.crs_places As CoursePlaces
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
		INTO #OldCourse
		FROM PDS_ATLAS_20150429.dbo.tbl_Course C
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_CourseType OldCT ON OldCT.ct_ID = C.crs_ct_id
		LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Module M ON M.mod_id = C.crs_mod_id
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_region_CourseType RCT ON RCT.rct_ct_id = C.crs_ct_id
																	AND RCT.rct_rgn_id = C.crs_rgn_id
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_Organisation_RegCrseType ORCT ON ORCT.orc_rct_id = RCT.rct_id
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation O ON O.org_id = ORCT.orc_org_id
		INNER JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Venue OldV ON OldV.vnu_ID = C.crs_vnu_ID
		;
		
		INSERT INTO Atlas_Dev.dbo.Course (
										CourseTypeId
										, DefaultStartTime
										, DefaultEndTime
										, Available
										, OrganisationId
										, Reference
										, CourseCategoryId
										, TempFieldPreviousCourseId
										)
		SELECT DISTINCT
			NewCT.Id AS CourseTypeId
			, OC.DefaultStartTime AS DefaultStartTime
			, OC.DefaultEndTime AS DefaultEndTime
			, 1 AS Available
			, NewO.Id AS OrganisationId
			, OC.Reference AS Reference
			, CC.Id AS CourseCategoryId
			, OC.CourseId AS PreviousCourseId
		FROM #OldCourse OC
		INNER JOIN Atlas_Dev.dbo.Organisation NewO ON NewO.Name = OC.OrganisationName
		INNER JOIN Atlas_Dev.dbo.CourseType NewCT ON NewCT.Title = OC.CourseTypeTitle
													AND NewCT.OrganisationId = NewO.Id
		LEFT JOIN Atlas_Dev.dbo.CourseCategory CC ON CC.Name = OC.CourseCategoryName
													AND CC.OrganisationId = NewO.Id
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.Course C
							WHERE C.CourseTypeId = NewCT.Id
							AND C.OrganisationId = NewO.Id
							AND C.Reference = OC.Reference
							AND C.CourseCategoryId = CC.Id
							)
		ORDER BY PreviousCourseId;
		
		--Populate CoursePreviousId
		BEGIN
			PRINT('');PRINT('*Populate CoursePreviousId');
			INSERT INTO Atlas_Dev.dbo.CoursePreviousId (CourseId, PreviousCourseId)
			SELECT DISTINCT Id AS CourseId, TempFieldPreviousCourseId AS PreviousCourseId
			FROM Atlas_Dev.dbo.Course C
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.CoursePreviousId CPI 
								WHERE CPI.CourseId = C.Id 
								AND CPI.PreviousCourseId = C.TempFieldPreviousCourseId
								)
			;
		END
	
		--Populate User with DataMigration User
		BEGIN
			PRINT('');PRINT('*Populate User with DataMigration User');
			INSERT INTO Atlas_Dev.dbo.[User] (LoginId, Name, Disabled)
			SELECT 'DataMigration' AS LoginId, 'DataMigration' AS Name, 'False' AS Disabled
			WHERE NOT EXISTS (SELECT * FROM Atlas_Dev.dbo.[User] U WHERE U.LoginId = 'DataMigration');
		END
		
		--Populate CourseNote
		BEGIN
			PRINT('');PRINT('*Populate CourseNote');
			INSERT INTO dbo.CourseNote (CourseId, CourseNoteTypeId, Note, CreatedByUserId, Removed)
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, CNT.Id AS CourseNoteTypeId
				, CAST(C.crs_notes AS varchar) AS Note
				, U.Id AS CreatedByUserId
				, 'False' AS Removed
			FROM PDS_ATLAS_20150429.dbo.tbl_Course C
			INNER JOIN Atlas_Dev.dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN Atlas_Dev.dbo.CourseNoteType CNT ON CNT.Title = 'General'
			INNER JOIN Atlas_Dev.dbo.[User] U ON U.LoginId = 'DataMigration'
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
				, U.Id AS CreatedByUserId
				, 'False' AS Removed
			FROM PDS_ATLAS_20150429.dbo.tbl_Course C
			INNER JOIN Atlas_Dev.dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN Atlas_Dev.dbo.CourseNoteType CNT ON CNT.Title = 'Instructor'
			INNER JOIN Atlas_Dev.dbo.[User] U ON U.LoginId = 'DataMigration'
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
				, U.Id AS CreatedByUserId
				, 'False' AS Removed
			FROM PDS_ATLAS_20150429.dbo.tbl_Course C
			INNER JOIN Atlas_Dev.dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			INNER JOIN Atlas_Dev.dbo.CourseNoteType CNT ON CNT.Title = 'Register'
			INNER JOIN Atlas_Dev.dbo.[User] U ON U.LoginId = 'DataMigration'
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
			PRINT('');PRINT('*Populate CourseDates');
			INSERT INTO Atlas_Dev.dbo.CourseDates (CourseId, DateStart, DateEnd, Available)
			SELECT DISTINCT
				CPI.CourseId AS CourseId
				, C.crs_date_Course AS DateStart
				, (CASE WHEN C.crs_isTwoDay = 'True' 
						THEN DATEADD(d, 1, C.crs_date_Course) 
						ELSE C.crs_date_Course END) AS DateEnd
				, 'True' AS Available
			FROM PDS_ATLAS_20150429.dbo.tbl_Course C
			INNER JOIN Atlas_Dev.dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			WHERE C.crs_date_Course IS NOT NULL
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseDates CD
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
			FROM PDS_ATLAS_20150429.dbo.tbl_Course C
			INNER JOIN Atlas_Dev.dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = C.crs_ID
			WHERE C.crs_date_Course2 IS NOT NULL
			AND NOT EXISTS (SELECT * 
							FROM dbo.CourseDates CD
							WHERE CD.DateStart = C.crs_date_Course2
							AND CD.CourseId = CPI.CourseId
							)
			;
		END
	END 
	/**************************************************************************************************/
	
	--POPULATE PaymentProvider
	BEGIN
		PRINT('');PRINT('*Populate PaymentProvider');
		INSERT INTO Atlas_Dev.dbo.PaymentProvider (Name, ProviderCode, ShortCode, OrganisationId)
		SELECT DISTINCT OldPP.pp_name AS Name
						, OldPP.pp_providerCode AS ProviderCode
						, OldPP.pp_shortCode AS ShortCode
						, O.Id AS OrganisationId
		FROM PDS_ATLAS_20150429.dbo.tbl_LU_PaymentProvider OldPP
		, Atlas_Dev.dbo.Organisation O
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.PaymentProvider NewPP 
							WHERE NewPP.Name = OldPP.pp_name
							AND ISNULL(NewPP.ProviderCode,'') = ISNULL(OldPP.pp_providerCode,'')
							AND ISNULL(NewPP.ShortCode,'') = ISNULL(OldPP.pp_shortCode,'')
							AND NewPP.OrganisationId = O.Id
							)
		ORDER BY O.Id
	END
	/**************************************************************************************************/

	--POPULATE PaymentMethod
	BEGIN
		PRINT('');PRINT('*Populate PaymentMethod');
		INSERT INTO Atlas_Dev.dbo.PaymentMethod (Name, Description, Code, OrganisationId, Disabled)
		SELECT pmm_description AS Name, pmm_description AS Description, pmm_code AS Code, NewOrg.Id AS OrganisationId, 'False' AS Disabled
		FROM [migration].dbo.tbl_LU_PaymentMethod OldPM
		, ([migration].tbl_LU_Organisation OldOrg
			INNER JOIN [dbo].Organisation NewOrg ON NewOrg.Name = OldOrg.org_name )
		WHERE NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.PaymentMethod NewPM
							WHERE NewPM.Name = OldPM.pmm_description
							AND NewPM.OrganisationId = NewOrg.Id
							)
	END
	/**************************************************************************************************/

	--*POPULATE Payment
	PRINT('');PRINT('*POPULATE Payment');
	IF OBJECT_ID('tempdb..#PaymentDetails', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #PaymentDetails;
	END

	IF OBJECT_ID('tempdb..#PaymentNotes', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #PaymentNotes;
	END

	BEGIN
		--Create PaymentDetails Temp Table
		BEGIN
			PRINT('');PRINT('Create PaymentDetails Temp Table');
			SELECT * 
			INTO #PaymentDetails
			FROM (
				SELECT
					OldPay1.pm_id AS OldPayId
					, OldPay1.pm_date AS DateCreated
					, OldPay1.pm_date AS TransactionDate
					, OldPay1.pm_amount AS Amount
					, OldPay1.pm_receiptNumber AS ReceiptNumber
					, OldPay1.pm_authCode AS AuthCode
					, OldPay1.pm_pmm_id AS OldPayMethodId
					, NewPM1.Id AS NewPayMethodId
					, OldPay1.pm_usr_id AS OldUserId
					, NewUp1.UserId AS NewUserId
					, NewO1.OrganisationId AS NewOrganisationId
					, OldPay1.pm_dr_id as OldClientId
					, NewCP1.ClientId as NewClientId
					, 'Migrated: ' + CONVERT(varchar(23), GETDATE(), 121) AS Comments
				FROM PDS_ATLAS_20150429.dbo.tbl_Payment OldPay1
				LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_PaymentMethod AS OldPM1 ON OldPM1.pmm_id = OldPay1.pm_pmm_id
				LEFT JOIN Atlas_Dev.dbo.PaymentMethod NewPM1 ON NewPM1.Name = OldPM1.pmm_description
															AND ISNULL(NewPM1.Code,'') = ISNULL(OldPM1.pmm_code,'')
				LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_Users OldU1 ON OldU1.usr_ID = OldPay1.pm_usr_id
				LEFT JOIN Atlas_Dev.dbo.UserPreviousId NewUp1 ON NewUp1.PreviousUserId = OldPay1.pm_usr_id
				LEFT JOIN Atlas_Dev.dbo.OrganisationUser NewO1 ON NewO1.UserId = NewUp1.UserId
				LEFT JOIN Atlas_Dev.dbo.ClientPreviousId NewCP1 ON NewCP1.PreviousClientId = OldPay1.pm_dr_id
				/*
				UNION ALL
				SELECT TOP 1000
					OldPay2.pa_id AS OldPayId
					, OldPay2.pa_date AS DateCreated
					, OldPay2.pa_date AS TransactionDate
					, OldPay2.pa_amount AS Amount
					, OldPay2.pa_receiptNumber AS ReceiptNumber
					, '' AS AuthCode
					, OldPay2.pa_pmm_id AS OldPayMethodId
					, NewPM1.Id AS NewPayMethodId
					, null AS OldUserId
					, NewU.Id AS NewUserId
					, null AS NewOrganisationId
					, OldPay2.pa_dr_id as OldClientId
					, NewCP1.ClientId as NewClientId
					, 'Archived: ' + CONVERT(varchar(23), OldPay2.pa_date_archived, 121)
						+ '; Course Type: ' + OldCT.ct_Description
						+ '; Name: ' + OldPay2.pa_firstname + ' ' + OldPay2.pa_lastname
						AS Comments
				FROM PDS_ATLAS_20150429.dbo.tbl_Payment_Archive OldPay2
				LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_PaymentMethod AS OldPM1 ON OldPM1.pmm_id = OldPay2.pa_pmm_id
				LEFT JOIN Atlas_Dev.dbo.PaymentMethod NewPM1 ON NewPM1.Name = OldPM1.pmm_description
															AND ISNULL(NewPM1.Code,'') = ISNULL(OldPM1.pmm_code,'')
				--LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_Users OldU1 ON OldU1.usr_ID = OldPay2.pa_usr_id
				--LEFT JOIN Atlas_Dev.dbo.UserPreviousId NewUp1 ON NewUp1.PreviousUserId = OldPay2.pa_usr_id
				--LEFT JOIN Atlas_Dev.dbo.OrganisationUser NewO1 ON NewO1.UserId = NewUp1.UserId
				LEFT JOIN Atlas_Dev.dbo.[User] NewU ON NewU.LoginId = 'UnknownUser'
				LEFT JOIN Atlas_Dev.dbo.ClientPreviousId NewCP1 ON NewCP1.PreviousClientId = OldPay2.pa_dr_id
				LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_CourseType OldCT ON OldCT.ct_ID = OldPay2.pa_ct_id
				--*/
				) AS PaymentDetails
		END
		
		--INSERT INTO Payment Table
		BEGIN
			PRINT('');PRINT('INSERT INTO Payment Table');
			INSERT INTO Atlas_Dev.dbo.Payment (
											DateCreated
											, TransactionDate
											, Amount
											, PaymentTypeId
											, PaymentMethodId
											, ReceiptNumber
											, AuthCode
											, CreatedByUserId
											, TempFieldPreviousPaymentId
											)
			SELECT DateCreated
					, TransactionDate
					, Amount
					, NULL AS PaymentTypeId
					, NewPayMethodId AS PaymentMethodId
					, ReceiptNumber
					, AuthCode
					, (CASE WHEN NewUserId IS NULL THEN NewU.Id ELSE NewUserId END) AS CreatedByUserId
					, OldPayId AS TempFieldPreviousPaymentId
			FROM #PaymentDetails PD
			LEFT JOIN Atlas_Dev.dbo.[User] NewU ON NewU.LoginId = 'UnknownUser'
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.Payment NewP
								WHERE NewP.DateCreated = PD.DateCreated
								AND NewP.TransactionDate = PD.TransactionDate
								AND NewP.ReceiptNumber = PD.ReceiptNumber
								AND NewP.Amount = PD.Amount
								)
		END
		
		--INSERT INTO PreviousPaymentId Table
		BEGIN
			PRINT('');PRINT('INSERT INTO PreviousPaymentId Table');
			INSERT INTO Atlas_Dev.dbo.PaymentPreviousId (PaymentId, PreviousPaymentId)
			SELECT P.Id AS PaymentId, P.TempFieldPreviousPaymentId AS PreviousPaymentId 
			FROM Atlas_Dev.dbo.Payment P
			WHERE P.TempFieldPreviousPaymentId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.PaymentPreviousId PPI
								WHERE PPI.PaymentId = P.Id
								AND PPI.PreviousPaymentId = P.TempFieldPreviousPaymentId)
		END
		
		--INSERT INTO PreviousPaymentId Table
		BEGIN
			PRINT('');PRINT('INSERT INTO PreviousPaymentId Table');
			INSERT INTO Atlas_Dev.dbo.ClientPayment (ClientId, PaymentId)
			SELECT PD.NewClientId AS ClientId, P.Id AS PaymentId
			FROM  #PaymentDetails PD
			INNER JOIN Atlas_Dev.dbo.Payment P ON P.TempFieldPreviousPaymentId = PD.OldPayId
			WHERE PD.NewClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.ClientPayment CP
								WHERE CP.ClientId = PD.NewClientId
								AND CP.PaymentId = P.Id)
		END

		--INSERT INTO ClientPaymentPreviousClientId Table
		BEGIN
			PRINT('');PRINT('INSERT INTO ClientPaymentPreviousClientId Table');
			INSERT INTO Atlas_Dev.dbo.ClientPaymentPreviousClientId (PaymentId, ClientId, PreviousClientId)
			SELECT P.Id AS PaymentId, PD.NewClientId AS ClientId, PD.OldClientId AS PreviousClientId
			FROM  #PaymentDetails PD
			INNER JOIN Atlas_Dev.dbo.Payment P ON P.TempFieldPreviousPaymentId = PD.OldPayId
			WHERE PD.OldClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.ClientPaymentPreviousClientId PCI
								WHERE PCI.PaymentId = P.Id
								AND PCI.ClientId = PD.NewClientId
								AND PCI.PreviousClientId = PD.OldClientId
								)
		END
		
		--INSERT INTO Client Payment Note Tables
		BEGIN
			PRINT('');PRINT('INSERT INTO Client Payment Note Tables');
		
			--Create Temp Table #PaymentNotes
			PRINT('');PRINT('Create Temp Table #PaymentNotes');
			SELECT P.Id AS PaymentId
				, PD.Comments AS Note
				, NT.Id AS NoteTypeId
				, NewU.Id AS UserId
				, PD.NewClientId AS ClientId
			INTO #PaymentNotes
			FROM #PaymentDetails PD
			INNER JOIN Atlas_Dev.dbo.Payment P ON P.TempFieldPreviousPaymentId = PD.OldPayId
			INNER JOIN Atlas_Dev.dbo.NoteType NT ON NT.Name = 'General'
			LEFT JOIN Atlas_Dev.dbo.[User] NewU ON NewU.LoginId = 'MigrationUser'
			WHERE LEN(PD.Comments) > 0;
			
			--INSERT INTO Note Table
			PRINT('');PRINT('INSERT INTO Note Table');
			INSERT INTO Atlas_Dev.dbo.Note (Note, DateCreated, CreatedByUserId, NoteTypeId, TempPaymentId)
			SELECT PN.Note
					, GETDATE() AS DateCreated
					, (CASE WHEN PN.UserId IS NULL THEN NewU.Id ELSE PN.UserId END) AS CreatedByUserId
					, PN.NoteTypeId
					, PN.PaymentId AS TempPaymentId
			FROM #PaymentNotes PN
			LEFT JOIN Atlas_Dev.dbo.[User] NewU ON NewU.LoginId = 'UnknownUser'
			WHERE NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.Note N
								WHERE N.TempPaymentId = PN.PaymentId
								)
			;
			
			--INSERT INTO ClientPaymentNote Table
			PRINT('');PRINT('INSERT INTO ClientPaymentNote Table');
			INSERT INTO Atlas_Dev.dbo.ClientPaymentNote (ClientId, PaymentId, NoteId)
			SELECT PN.ClientId, PN.PaymentId, N.Id AS NoteId
			FROM Atlas_Dev.dbo.Note N
			INNER JOIN #PaymentNotes PN ON PN.PaymentId = N.TempPaymentId
			WHERE N.TempPaymentId IS NOT NULL
			AND PN.ClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM Atlas_Dev.dbo.ClientPaymentNote CPN
								WHERE CPN.ClientId = PN.ClientId
								AND CPN.PaymentId = PN.PaymentId
								AND CPN.NoteId = N.Id
								)
			;
			
		END
		
	END
	
	/**************************************************************************************************/
	
	--*Populate Organisation User Administrators
	BEGIN
		PRINT('');PRINT('*Populate Organisation User Administrators');
		INSERT INTO Atlas_Dev.dbo.OrganisationAdminUser (OrganisationId, UserId)
		SELECT DISTINCT NewOrgId AS OrganisationId, NewUserId AS UserId
		FROM (
			SELECT O.org_name AS Organisation
				, N_O.Name AS NewOrgName
				, N_O.Id AS NewOrgId
				, ALG.alg_name AS AdminGroup
				, AL.adm_name AS AdminName
				, U.usr_Fullname AS UserName
				, N_U.Name AS NewUserName
				, N_U.Id AS NewUserId
				, SI.si_code AS Security
				, (CASE WHEN AL.adm_all_groups = 'true' THEN 'True' ELSE 'False' END) AS AllGroups
				
			FROM PDS_ATLAS_20150429.dbo.tbl_Users U
			LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_LU_Organisation O ON O.org_id = U.usr_org_id
			LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_AdminLevels AL ON AL.adm_id = U.usr_adm_id
			LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_AdminLevels_Groups ALG ON ALG.alg_id = AL.adm_alg_id
			LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_AdminLevels_SecurityItems ALSI ON ALSI.als_adm_id = AL.adm_id
			LEFT JOIN PDS_ATLAS_20150429.dbo.tbl_SecurityItems SI ON SI.si_id = ALSI.als_si_id
			LEFT JOIN Atlas_Dev.dbo.Organisation N_O ON N_O.Name = O.org_name
			LEFT JOIN Atlas_Dev.dbo.UserPreviousId N_UPI ON N_UPI.PreviousUserId = U.usr_ID
			LEFT JOIN Atlas_Dev.dbo.[User] N_U ON N_U.Id = N_UPI.UserId
			WHERE U.usr_deleted = 'false'
			--ORDER BY O.org_name
			--	, ALG.alg_name
			--	, AL.adm_name
			--	, U.usr_Fullname
			--	, SI.si_code
				) N_OAU
		WHERE N_OAU.Security = 'ADMIN_USERS'
		AND NOT EXISTS (SELECT * 
							FROM Atlas_Dev.dbo.OrganisationAdminUser OAU
							WHERE OAU.OrganisationId = N_OAU.NewOrgId
							AND OAU.UserId = N_OAU.NewUserId
							)
	END
	
	
---***THIS SCRIPT IS INCOMPLETE

	--Tidy Up Temp Tables
	BEGIN
		PRINT('');PRINT('*Tidy Up Temp Tables');
		IF OBJECT_ID('tempdb..#Venue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #Venue;
		END
		
		IF OBJECT_ID('tempdb..#OldClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldClient;
		END

		IF OBJECT_ID('tempdb..#OldCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldCourse;
		END		
		
		IF OBJECT_ID('tempdb..#TempPhoneNumbersAndAddresses', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TempPhoneNumbersAndAddresses;
		END
		
		IF OBJECT_ID('tempdb..#PaymentDetails', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentDetails;
		END

		IF OBJECT_ID('tempdb..#PaymentNotes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentNotes;
		END

	END
	
GO;

PRINT('');PRINT('*Tidy Up Temp Columns');
-- Remove the Temp Column on the Course Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Course
	DROP COLUMN TempFieldPreviousCourseId;
END
GO

-- Remove the Temp Column on the Client Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Client
	DROP COLUMN TempFieldPreviousClientId;
END
GO

-- Remove the Temp Column on the Location Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Location
	DROP COLUMN TempFieldId;
END
GO

-- Remove the Temp Column on the Email Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Email
	DROP COLUMN TempFieldId;
END
GO

-- Remove the Temp Column on the Payment Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Payment
	DROP COLUMN TempFieldPreviousPaymentId;
END
GO

-- Remove the Temp Column on the Note Table
BEGIN
	ALTER TABLE Atlas_Dev.dbo.Note
	DROP COLUMN TempPaymentId;
END
GO



PRINT('');PRINT('*****FINISHED');


