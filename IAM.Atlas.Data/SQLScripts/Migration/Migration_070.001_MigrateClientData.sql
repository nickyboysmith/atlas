

/*
	Data Migration Script :- Migrate Client Data.
	Script Name: Migration_070.001_MigrateClientData.sql
	Author: Robert Newnham
	Created: 09/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Course Data has been Migrated.

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_070.001_MigrateClientData.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	-- Add a Temp Column to the Client Table. This will be removed further down this Script
	BEGIN
		ALTER TABLE dbo.Client
		ADD TempFieldPreviousClientId int NULL;
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

/**************************************************************************************************/

	DECLARE @LiveMigration BIT = 'True';
	DECLARE @MigrateDataFor VARCHAR(200) = 'Cleveland Driver Improvement Group';
	DECLARE @MigrateDataForOldId INT = (SELECT TOP 1 [org_id] FROM migration.[tbl_LU_Organisation] WHERE [org_name] = @MigrateDataFor);
	DECLARE @MigrateDataForNewId INT = (SELECT TOP 1 Id FROM [dbo].[Organisation] WHERE [Name] = @MigrateDataFor);

	PRINT('');PRINT('*Migrating Data For: ' + @MigrateDataFor 
					+ ' .... OldSystemID: ' + CAST(@MigrateDataForOldId AS VARCHAR)
					+ ' .... NewSystemID: ' + CAST(@MigrateDataForNewId AS VARCHAR)
					);


	PRINT('');PRINT('*Migrate Client Data Tables ' + CAST(GETDATE() AS VARCHAR));

	DECLARE @True bit, @False bit;
	SET @True = 'True';
	SET @False = 'False';

	DECLARE @SysUserId int;
	DECLARE @MigrationUserId int
	DECLARE @UnknownUserId int;
	SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
	SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
	SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';
	
/********************************************************************************************************************/
	
/******************* PDS_ATLAS "Driver" Table to "Client" table in New Atlas ***********************/
	BEGIN

		--Create Temp Table #OldClient
		BEGIN
			PRINT('');PRINT('*Create Temp Table #OldClient ' + CAST(GETDATE() AS VARCHAR));
			IF OBJECT_ID('tempdb..#OldClient', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #OldClient;
			END

			SELECT DISTINCT 
				OldDR.dr_ID AS Id
				, OldDR.dr_Title AS Title
				, (CASE WHEN Charindex(' ', OldDR.dr_firstname) > 0 
						THEN Substring(OldDR.dr_firstname, 1,Charindex(' ', OldDR.dr_firstname) - 1) 
						ELSE OldDR.dr_firstname
						END
					) AS FirstName
				, OldDR.dr_lastname AS Surname
				, (CASE WHEN Charindex(' ', OldDR.dr_firstname) > 0 
						THEN Substring(OldDR.dr_firstname
										, Charindex(' ', OldDR.dr_firstname)
										, LEN(OldDR.dr_firstname) - Charindex(' ', OldDR.dr_firstname) + 1
										) 
						ELSE ''
						END
					) AS OtherNames
				, LTRIM(RTRIM(
						LTRIM(RTRIM(ISNULL(OldDR.dr_Title,'')))
						+ ' ' + LTRIM(RTRIM(ISNULL(OldDR.dr_firstname,'')))
						+ ' ' + LTRIM(RTRIM(ISNULL(OldDR.dr_lastname,'')))
						)) AS DisplayName
				, OldDRD.drd_date_birth AS DateOfBirth
				, UPI.UserId AS CreatedByUserId
				, OldDR.[dr_date_recordCreated] AS DateCreated
				, OldDR.[dr_referrer_org_ID]
				, OldDR.[dr_referrer_rgn_ID]
				, OldDR.[dr_provider_rgn_id]
				, OldDR.dr_licenceNo AS [LicenceNumber]
				, OldDR.dr_policeRefNo AS [PoliceReference]
				, ISNULL(OldDR.[dr_addedSelf], 'False') AS BookedOnline
				, ISNULL(OldDR.[dr_didAttend], 'False') AS DidAttend
				, ISNULL(OldDR.[dr_hasPaid], 'False') AS HasPaid
				, ISNULL(OldDR.dr_smsOptOut, 'False') AS SmsOptOut
				, CAST((CASE WHEN OldDR.dr_emailCourseReminder IS NULL 
						THEN 'False'
						ELSE 'True' 
						END) AS BIT) AS EmailCourseReminder
				, OldOrg.org_id			AS OrgId
			INTO #OldClient
			FROM [dbo].[_Migration_DriverClientOrganisation] M_DCO
			INNER JOIN migration.tbl_Driver OldDR							ON OldDR.dr_ID = M_DCO.OldDriverId
			INNER JOIN migration.tbl_Driver_Data OldDRD						ON OldDRD.drd_dr_ID = OldDR.dr_ID
			---------------------------------------------------------------------------------------------------------
			--INNER JOIN migration.tbl_LU_Region OldR							ON OldR.rgn_id = OldDR.dr_provider_rgn_id
			--INNER JOIN migration.[tbl_Region_CourseType] OldRCT				ON OldRCT.rct_rgn_id = OldDR.dr_provider_rgn_id
			--INNER JOIN migration.[tbl_Organisation_RegCrseType] OldORCT		ON OldORCT.orc_rct_id = OldRCT.rct_id
			--INNER JOIN migration.tbl_LU_Organisation OldOrg					ON OldOrg.org_id = OldORCT.orc_org_id

			--INNER JOIN migration.tbl_LU_Organisation OldOrg					ON OldOrg.org_id = OldORCT.[dr_currentOrgId]
			INNER JOIN migration.tbl_LU_Organisation OldOrg					ON OldOrg.org_id = M_DCO.OldOrgId
			---------------------------------------------------------------------------------------------------------
			LEFT JOIN [dbo].[UserPreviousId] UPI							ON UPI.PreviousUserId = OldDR.[dr_addedBy_usr_id]
			--So as not to Process the Same again
			LEFT JOIN dbo.ClientPreviousId CPI								ON CPI.PreviousClientId = OldDR.dr_ID
			
			WHERE M_DCO.OldOrgId = @MigrateDataForOldId
			AND ISNULL(OldDR.[dr_anonymised], 'False') = 'False'
			AND OldDR.dr_lastname IS NOT NULL
			AND OldDR.dr_lastname != '(anonymised)'
			AND CPI.Id IS NULL; --ie not already processed
			--WHERE OldOrg.org_id = @MigrateDataForOldId
		END

		--POPULATE Client Table
		BEGIN
			PRINT('');PRINT('*POPULATE Client Table ' + CAST(GETDATE() AS VARCHAR));
					
			INSERT INTO dbo.Client (
				Title
				, FirstName
				, Surname
				, OtherNames
				, DisplayName
				, DateOfBirth
				, Locked
				, [DateCreated]
				, CreatedByUserId
				, [UpdatedByUserId]
				, [DateUpdated]
				, [EmailCourseReminders]
				, [SMSCourseReminders]
				, [SelfRegistration]
				, TempFieldPreviousClientId
				)
			SELECT OldClient.Title
				, OldClient.FirstName
				, OldClient.Surname
				, OldClient.OtherNames
				, OldClient.DisplayName AS DisplayName
				, OldClient.DateOfBirth
				, CAST('False' as bit) AS Locked
				, OldClient.[DateCreated]
				, OldClient.CreatedByUserId
				, @MigrationUserId AS [UpdatedByUserId]
				, GETDATE() AS [DateUpdated]
				, OldClient.EmailCourseReminder AS [EmailCourseReminders]
				, (CASE WHEN SmsOptOut = 'True'
						THEN 'False'
						ELSE 'True' END)	AS [SMSCourseReminders]
				, OldClient.BookedOnline	AS [SelfRegistration]
				, OldClient.Id				AS TempFieldPreviousClientId
			FROM #OldClient OldClient
			LEFT JOIN dbo.ClientPreviousId CPI ON CPI.PreviousClientId = OldClient.Id --If the Client is on this table then they have already been Migrated
			WHERE CPI.Id IS NULL;
		
			PRINT('');PRINT('*POPULATE ClientPreviousId Table ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPreviousId (ClientId, PreviousClientId, DateAdded, PreviousOrgId
											, PreviousReferrerOrgId, PreviousReferrerRgnId, PreviousProviderRgnId)
			SELECT NewClient.Id AS ClientId
				, NewClient.TempFieldPreviousClientId AS PreviousClientId
				, GETDATE() AS DateAdded
				, OldClient.OrgId AS PreviousOrgId
				, OldClient.[dr_referrer_org_ID] AS PreviousReferrerOrgId
				, OldClient.[dr_referrer_rgn_ID] AS PreviousReferrerRgnId
				, OldClient.[dr_provider_rgn_id] AS PreviousProviderRgnId
			FROM dbo.Client NewClient
			INNER JOIN #OldClient OldClient ON OldClient.Id = NewClient.TempFieldPreviousClientId
			LEFT JOIN dbo.ClientPreviousId CPI ON CPI.PreviousClientId = NewClient.TempFieldPreviousClientId
			WHERE NewClient.TempFieldPreviousClientId IS NOT NULL
			AND CPI.Id IS NULL;
		

			DECLARE @FemaleId int; SELECT TOP 1 @FemaleId = Id FROM dbo.Gender WHERE Name = 'Female';
			DECLARE @MaleId int; SELECT TOP 1 @MaleId = Id FROM dbo.Gender WHERE Name = 'Male';
			DECLARE @UnknownGenderId int; SELECT TOP 1 @UnknownGenderId = Id FROM dbo.Gender WHERE Name = 'Unknown';
			
			PRINT('');PRINT('*Set Client Gender Where known.... ' + CAST(GETDATE() AS VARCHAR));

			UPDATE dbo.Client
			SET GenderId = @FemaleId
			WHERE Title IN ('Mrs', 'Miss', 'Ms', 'The Countess Of', 'The Countess', 'Lady'
							, 'Countess', 'Dame', 'Queen', 'Madam', 'Madame', 'Baroness'
							, 'Sister', 'Mrfs', 'Maid', 'Princess', 'Tsarina', 'Grand Duchess'
							, 'Mother', 'Senora','Senorita', 'The Honourable Mrs', 'Contessa'
							, 'The Honourable Dame','Mademoiselle', 'Mamsell', 'Mistress'
							, 'Her Honour'
							)
			AND (GenderId IS NULL OR GenderId = @UnknownGenderId);

			UPDATE dbo.Client
			SET GenderId = @MaleId
			WHERE Title IN ('Mr', 'Master', 'Lord', 'Sir', 'Duke', 'Father', 'Count', 'Mister'
							, 'Sr.', 'Vicount', 'Viscount', 'Esq', 'Baron', 'Sr', 'Qari', 'Prince'
							, 'King', 'Earl', 'Tsar', 'Grand Duke', 'Friar', 'Monsignor', 'Monsieur'
							, 'Herr','Senor', 'Imam', 'Sheik', 'Sheikh', 'Brother', 'The Honourable Mr'
							, 'The Honourable Sir', 'His Honour'
							)
			AND (GenderId IS NULL OR GenderId = @UnknownGenderId);
	
			UPDATE dbo.Client
			SET GenderId = @UnknownGenderId
			WHERE GenderId IS NULL;
	
		END

		--POPULATE ClientLicence Table
		BEGIN
			PRINT('');PRINT('*POPULATE ClientLicence Table ' + CAST(GETDATE() AS VARCHAR));
					
			INSERT INTO dbo.ClientLicence (ClientId, LicenceNumber)
			SELECT DISTINCT CPI.ClientId, OldClient.[LicenceNumber]
			FROM #OldClient OldClient
			INNER JOIN [dbo].[ClientPreviousId] CPI ON CPI.PreviousClientId = OldClient.Id
			LEFT JOIN dbo.ClientLicence CL ON CL.ClientId = CPI.ClientId
											AND CL.LicenceNumber = OldClient.[LicenceNumber]
			WHERE LEN(OldClient.[LicenceNumber]) > 0
			AND CL.Id IS NULL;
	
		END

		--POPULATE ClientReference Table
		BEGIN
			PRINT('');PRINT('*POPULATE ClientReference Table ' + CAST(GETDATE() AS VARCHAR));
					
			INSERT INTO dbo.ClientReference (ClientId, IsPoliceReference, Reference, CreatedByUserId, DateCreated)
			SELECT DISTINCT CPI.ClientId AS ClientId
							, 'True' AS IsPoliceReference
							, OldClient.[PoliceReference] AS Reference
							, @MigrationUserId AS CreatedByUserId
							, GETDATE() AS DateCreated
			FROM #OldClient OldClient
			INNER JOIN [dbo].[ClientPreviousId] CPI ON CPI.PreviousClientId = OldClient.Id
			LEFT JOIN dbo.ClientReference CR ON CR.ClientId = CPI.ClientId
											AND CR.Reference = OldClient.[PoliceReference]
			WHERE LEN(OldClient.[PoliceReference]) > 0
			AND CR.Id IS NULL;	
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
			PRINT('');PRINT('*SET Phone Type ID Variables ' + CAST(GETDATE() AS VARCHAR));
			SELECT @WorkTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Work';
			SELECT @HomeTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Home';
			SELECT @MobileTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Mobile';
			SELECT @FaxTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Fax';
			SELECT @OtherTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Other';
			SELECT @OnlineTypeId = Id FROM dbo.PhoneType PT WHERE PT.[Type] = 'Online';
		END
	
		--Temp Table for Client Phone Numbers and Addresses
		BEGIN
			PRINT('');PRINT('*Create Temp Table for Client Phone Numbers and Addresses ' + CAST(GETDATE() AS VARCHAR));
			IF OBJECT_ID('tempdb..#TempPhoneNumbersAndAddresses', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #TempPhoneNumbersAndAddresses;
			END

			SELECT 
				NewClient.Id AS ClientId
				, LTRIM(RTRIM(CAST(ISNULL(OldClientData.drd_address,'') AS Varchar(500)))) AS ClientAddress
				, LTRIM(RTRIM(ISNULL(OldClient.dr_postcode,''))) AS ClientPostCode
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_telHome,''))) AS ClientPhone_Home
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_telWork,''))) AS ClientPhone_Work
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_telMobile,''))) AS ClientPhone_Mobile --, '555 ' + (CAST (NewClient.Id AS VARCHAR))  AS ClientPhone_Mobile			--
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_telFax,''))) AS ClientPhone_Fax
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_emailAddress,''))) AS ClientEmail --, 'FakeC' + (CAST (NewClient.Id AS VARCHAR)) + '@iamFakeEmail.com'	 AS ClientEmail							-- 
				, LTRIM(RTRIM(ISNULL(OldClientData.drd_online_contactNumber,''))) AS ClientPhone_OnlineContactNumber
			INTO #TempPhoneNumbersAndAddresses
			FROM dbo.Client NewClient
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.ClientId = NewClient.Id
			INNER JOIN #OldClient tempTable ON tempTable.Id = NewClientPrev.PreviousClientId -- ie only the new ones just processed
			INNER JOIN migration.tbl_Driver OldClient ON OldClient.dr_ID = NewClientPrev.PreviousClientId
			INNER JOIN migration.tbl_Driver_Data OldClientData ON OldClientData.drd_dr_ID = NewClientPrev.PreviousClientId
			ORDER BY NewClient.Id;
		END
		
		--*Save Phone Numbers
		--Home
		BEGIN
			PRINT('');PRINT('*Save Client Home Phone Numbers ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
			SELECT DISTINCT ClientId
							, @HomeTypeId AS PhoneTypeId
							, CAST(ClientPhone_Home AS Varchar(40)) AS PhoneNumber
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientPhone_Home) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.ClientPhone P 
							WHERE P.ClientId = ClientId
							AND P.PhoneTypeId = @HomeTypeId
							AND P.PhoneNumber = CAST(ClientPhone_Home AS Varchar(40))
							);
		END
	
		-- Work
		BEGIN
			PRINT('');PRINT('*Save Client Work Phone Numbers ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
			SELECT DISTINCT ClientId
							, @WorkTypeId AS PhoneTypeId
							, CAST(ClientPhone_Work AS Varchar(40)) AS PhoneNumber
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientPhone_Work) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.ClientPhone P 
							WHERE P.ClientId = ClientId
							AND P.PhoneTypeId = @WorkTypeId
							AND P.PhoneNumber = CAST(ClientPhone_Work AS Varchar(40))
							);
		END

		-- Mobile
		BEGIN
			PRINT('');PRINT('*Save Client Mobile Phone Numbers ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
			SELECT DISTINCT ClientId
							, @MobileTypeId AS PhoneTypeId
							, CAST(ClientPhone_Mobile AS Varchar(40)) AS PhoneNumber
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientPhone_Mobile) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.ClientPhone P 
							WHERE P.ClientId = ClientId
							AND P.PhoneTypeId = @MobileTypeId
							AND P.PhoneNumber = CAST(ClientPhone_Mobile AS Varchar(40))
							);				
		END
			
		-- Fax
		BEGIN
			PRINT('');PRINT('*Save Client Fax Numbers ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
			SELECT DISTINCT ClientId
							, @FaxTypeId AS PhoneTypeId
							, CAST(ClientPhone_Fax AS Varchar(40)) AS PhoneNumber
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientPhone_Fax) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.ClientPhone P 
							WHERE P.ClientId = ClientId
							AND P.PhoneTypeId = @FaxTypeId
							AND P.PhoneNumber = CAST(ClientPhone_Fax AS Varchar(40))
							);
		END
	
		-- Online
		BEGIN
			PRINT('');PRINT('*Save Client Online Phone Numbers ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPhone (ClientId, PhoneTypeId, PhoneNumber)
			SELECT DISTINCT ClientId
							, @OnlineTypeId AS PhoneTypeId
							, CAST(ClientPhone_OnlineContactNumber AS Varchar(40)) AS PhoneNumber
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientPhone_OnlineContactNumber) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.ClientPhone P 
							WHERE P.ClientId = ClientId
							AND P.PhoneTypeId = @OnlineTypeId
							AND P.PhoneNumber = CAST(ClientPhone_OnlineContactNumber AS Varchar(40))
							);
		END
	
		--*Save Addresses
		BEGIN
			PRINT('');PRINT('*Save Client Addresses ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Location ([Address], PostCode, TempFieldId)
			SELECT DISTINCT ClientAddress AS [Address]
							, UPPER(CAST(ClientPostCode AS Varchar(20))) AS PostCode
							, ClientId AS TempFieldId
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientAddress) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.Location P 
							WHERE P.TempFieldId = ClientId
							AND P.[Address] = ClientAddress
							AND P.PostCode = UPPER(CAST(ClientPostCode AS Varchar(20)))
							);
						
			INSERT INTO dbo.ClientLocation (ClientId, LocationId)
			SELECT DISTINCT TempFieldId AS ClientId, L.Id AS LocationId
			FROM dbo.Location L
			INNER JOIN dbo.Client C ON C.Id = L.TempFieldId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.ClientLocation CA 
								WHERE CA.ClientId = L.TempFieldId
								AND CA.LocationId = L.Id
								);
		END
		
		--*Save Notes
		BEGIN
			PRINT('');PRINT('*Save Client Notes ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Note ([Note], DateCreated, CreatedByUserId, Removed, NoteTypeId, TempFieldId)
			SELECT DISTINCT 
				[Note]					AS [Note]
				, GETDATE()				AS DateCreated
				, @MigrationUserId		AS CreatedByUserId
				, 'False'				AS Removed
				, T.NoteTypeId			AS NoteTypeId
				, T.TempFieldId			AS TempFieldId
			FROM (
				SELECT CAST(OldDrData.drd_notes AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'General') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notes IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_PrivateNotes AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Private') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_PrivateNotes IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_ReferrerNotes AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Referrer') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_ReferrerNotes IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_notesOther AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Other') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notesOther IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_notes_rejection AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Rejection') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notes_rejection IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_notes_general AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'General') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notes_general IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_notes_courseRegister AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Register') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notes_courseRegister IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				UNION SELECT CAST(OldDrData.drd_notes_pending AS VARCHAR)		AS [Note]
						, (SELECT TOP 1 Id FROM dbo.NoteType NT WHERE NT.[Name] = 'Other') AS NoteTypeId
						, NewClientPrev.ClientId AS TempFieldId
				FROM migration.tbl_Driver OldDr
				INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldDr.dr_ID
				INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
				WHERE OldDrData.drd_notes_pending IS NOT NULL
				AND NOT EXISTS (SELECT * FROM dbo.ClientNote CN WHERE CN.ClientId = NewClientPrev.ClientId) -- Clients' Nots Not Already Created
				---------------------------------------------------------------------------------------------
				) T
				;
				
				PRINT('');PRINT('*Save Client Note ' + CAST(GETDATE() AS VARCHAR));
				INSERT INTO dbo.ClientNote (ClientId, NoteId)
				SELECT DISTINCT C.Id AS ClientId, N.Id AS NoteId
				FROM dbo.Note N
				INNER JOIN dbo.Client C ON C.Id = N.TempFieldId
				LEFT JOIN dbo.ClientNote CN ON CN.ClientId = C.Id
											AND CN.NoteId = N.Id 
				WHERE N.TempFieldId IS NOT NULL
				AND CN.Id IS NULL;
		END
	
		--*Save EmailAddresses
		BEGIN
			PRINT('');PRINT('*Save Client Email ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Email ([Address], TempFieldId)
			SELECT DISTINCT ClientEmail AS [Address], ClientId AS TempFieldId
			FROM #TempPhoneNumbersAndAddresses
			WHERE LEN(ClientEmail) > 0
			AND NOT EXISTS(SELECT * 
							FROM dbo.Email P 
							WHERE P.TempFieldId = ClientId
							AND P.[Address] = ClientEmail
							);
						
			INSERT INTO dbo.ClientEmail (ClientId, EmailId)
			SELECT DISTINCT TempFieldId AS ClientId, E.Id AS EmailId
			FROM dbo.Email E
			INNER JOIN dbo.Client C ON C.Id = E.TempFieldId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.ClientEmail CE 
								WHERE CE.ClientId = E.TempFieldId
								AND CE.EmailId = E.Id
								);
		END
	
		--*Save Client Organisation
		BEGIN
			PRINT('');PRINT('*Save Client Organisation ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientOrganisation (ClientId, OrganisationId)
			SELECT DISTINCT NewClientPrev.ClientId, NewOrg.Id AS OrganisationId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldClient.Id
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.ClientOrganisation CO 
								WHERE CO.ClientId = NewClientPrev.ClientId
								AND CO.OrganisationId = NewOrg.Id
								)
			;
		END

		--*Client Special Requirements
		/*
			SELECT 'Has Difficulty Reading and Writing' AS SpecReq
			UNION SELECT 'Is Deaf' AS SpecReq
			UNION SELECT 'Wheel Chair User' AS SpecReq
			UNION SELECT 'Accompanied By a Translator' AS SpecReq
			UNION SELECT 'Accompanied By a Career' AS SpecReq
			*/
		BEGIN
			PRINT('');PRINT('*Save Client Special Requirements ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientSpecialRequirement (ClientId, SpecialRequirementId, DateAdded, AddByUserId)
			---------------------------------------------------------------------------------------------------
			SELECT DISTINCT 
				NewClientPrev.ClientId	AS ClientId
				, SR.Id					AS SpecialRequirementId
				, GETDATE()				AS DateAdded
				, @MigrationUserId		AS AddByUserId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_Driver OldDr ON OldDr.dr_ID = OldClient.Id
			INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldClient.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
			INNER JOIN [dbo].[SpecialRequirement] SR ON SR.[Name] = 'Has Difficulty Reading and Writing'
													AND SR.[OrganisationId] = NewOrg.Id
			WHERE ISNULL(OldDrData.drd_hasDifficultyReadingWriting, 'False') = 'True'
			----------------------------------------------------------------------------------------------
			UNION SELECT DISTINCT 
				NewClientPrev.ClientId	AS ClientId
				, SR.Id					AS SpecialRequirementId
				, GETDATE()				AS DateAdded
				, @MigrationUserId		AS AddByUserId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_Driver OldDr ON OldDr.dr_ID = OldClient.Id
			INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldClient.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
			INNER JOIN [dbo].[SpecialRequirement] SR ON SR.[Name] = 'Is Deaf'
													AND SR.[OrganisationId] = NewOrg.Id
			WHERE ISNULL(OldDrData.drd_isDeaf, 'False') = 'True'
			----------------------------------------------------------------------------------------------
			UNION SELECT DISTINCT 
				NewClientPrev.ClientId	AS ClientId
				, SR.Id					AS SpecialRequirementId
				, GETDATE()				AS DateAdded
				, @MigrationUserId		AS AddByUserId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_Driver OldDr ON OldDr.dr_ID = OldClient.Id
			INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldClient.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
			INNER JOIN [dbo].[SpecialRequirement] SR ON SR.[Name] = 'Wheel Chair User'
													AND SR.[OrganisationId] = NewOrg.Id
			WHERE ISNULL(OldDrData.drd_wheelchairUser, 'False') = 'True'
			----------------------------------------------------------------------------------------------
			UNION SELECT DISTINCT 
				NewClientPrev.ClientId	AS ClientId
				, SR.Id					AS SpecialRequirementId
				, GETDATE()				AS DateAdded
				, @MigrationUserId		AS AddByUserId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_Driver OldDr ON OldDr.dr_ID = OldClient.Id
			INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldClient.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
			INNER JOIN [dbo].[SpecialRequirement] SR ON SR.[Name] = 'Accompanied By a Translator'
													AND SR.[OrganisationId] = NewOrg.Id
			WHERE ISNULL(OldDrData.drd_accompaniedByTranslator, 'False') = 'True'
			----------------------------------------------------------------------------------------------
			UNION SELECT DISTINCT 
				NewClientPrev.ClientId	AS ClientId
				, SR.Id					AS SpecialRequirementId
				, GETDATE()				AS DateAdded
				, @MigrationUserId		AS AddByUserId
			FROM #OldClient OldClient
			INNER JOIN migration.tbl_Driver OldDr ON OldDr.dr_ID = OldClient.Id
			INNER JOIN migration.tbl_Driver_Data OldDrData ON OldDrData.drd_dr_ID = OldClient.Id
			INNER JOIN migration.tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldClient.OrgId
			INNER JOIN dbo.ClientPreviousId NewClientPrev ON NewClientPrev.PreviousClientId = OldDr.dr_ID
			INNER JOIN dbo.Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name
			INNER JOIN [dbo].[SpecialRequirement] SR ON SR.[Name] = 'Accompanied By a Career'
													AND SR.[OrganisationId] = NewOrg.Id
			WHERE ISNULL(OldDrData.drd_accompaniedByCarer, 'False') = 'True'
			----------------------------------------------------------------------------------------------


			--WHERE NOT EXISTS (SELECT * 
			--					FROM dbo.ClientOrganisation CO 
			--					WHERE CO.ClientId = NewClientPrev.ClientId
			--					AND CO.OrganisationId = NewOrg.Id
			--					)
			--;
		END

	END

/********************************************************************************************************************/

	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));
		
		PRINT('');PRINT('*Tidy Up Temp Tables ' + CAST(GETDATE() AS VARCHAR));
		IF OBJECT_ID('tempdb..#OldClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OldClient;
		END

		IF OBJECT_ID('tempdb..#TempPhoneNumbersAndAddresses', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TempPhoneNumbersAndAddresses;
		END
		
	END

	PRINT('');PRINT('*Tidy Up Temp Columns ' + CAST(GETDATE() AS VARCHAR));

	-- Remove the Temp Column on the Client Table
	BEGIN
		ALTER TABLE dbo.Client
		DROP COLUMN TempFieldPreviousClientId;
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




	
PRINT('');PRINT('**Completed Script: "Migration_070.001_MigrateClientData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/


