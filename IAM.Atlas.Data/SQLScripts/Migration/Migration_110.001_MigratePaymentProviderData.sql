


/*
	Data Migration Script :- Migrate Payment Provider Data.
	Script Name: Migration_110.001_MigratePaymentProviderData.sql
	Author: Robert Newnham
	Created: 15/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Client or Course Data has been Migrated.

*/

/*
	Old Tables Data Migrated So Far
*/


/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_110.001_MigratePaymentProviderData.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/
	--*Payment Provider Data
	BEGIN
		PRINT('');PRINT('*Populate Payment Provider Data Tables ' + CAST(GETDATE() AS VARCHAR));
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

	END

	BEGIN	
		PRINT('');PRINT('*Ensure Payment Providers Exist* ' + CAST(GETDATE() AS VARCHAR));
	
		DECLARE @CurrentSystemType VARCHAR(4);
		SELECT @CurrentSystemType=AtlasSystemType FROM dbo.SystemControl WHERE [Id] = 1;

		IF OBJECT_ID('tempdb..#PaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProvider;
		END
	
		DECLARE @SecureTrading VARCHAR(200) = 'Secure Trading';
		DECLARE @BarclaysSmartPay VARCHAR(200) = 'Barclays Smart Pay';
		DECLARE @NetBanx VARCHAR(200) = 'NetBanx';
		
		PRINT('');PRINT('-INSERT INTO #PaymentProvider ' + CAST(GETDATE() AS VARCHAR));
		SELECT [Name], [Disabled], [NOTES], [SystemDefault]
		INTO #PaymentProvider
		FROM (
			SELECT @SecureTrading AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'True' AS [SystemDefault]
			UNION SELECT @BarclaysSmartPay AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'False' AS [SystemDefault]
			UNION SELECT @NetBanx AS [Name], 'False' AS [Disabled], '' AS [NOTES], 'False' AS [SystemDefault]
			) PP
		
		PRINT('');PRINT('-INSERT INTO dbo.PaymentProvider ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.PaymentProvider ([Name], [Disabled], [NOTES], [SystemDefault])
		SELECT [Name], [Disabled], [NOTES], [SystemDefault]
		FROM #PaymentProvider NewPP
		WHERE NOT EXISTS (SELECT * 
							FROM dbo.PaymentProvider PP
							WHERE PP.[Name] = NewPP.[Name]);
							
		-- Update Table OrganisationPaymentProvider
		IF OBJECT_ID('tempdb..#OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProvider;
		END
				
		-- OrganisationPaymentProviderMatch
		IF OBJECT_ID('tempdb..#OrganisationPaymentProviderMatch', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProviderMatch;
		END
		
		PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProviderMatch ' + CAST(GETDATE() AS VARCHAR));
		SELECT OrganisationName, PPName
		INTO #OrganisationPaymentProviderMatch
		FROM (
				--Secure Trading
				SELECT 'Cleveland' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Durham' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Essex' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Gloucestershire' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Norfolk' AS OrganisationName, @SecureTrading AS PPName
				UNION SELECT 'Staffordshire' AS OrganisationName, @SecureTrading AS PPName
				-- NetBanx
				UNION SELECT 'Sussex' AS OrganisationName, @NetBanx AS PPName
				-- Barclays Smart Pay
				UNION SELECT 'DriveSafe' AS OrganisationName, @BarclaysSmartPay AS PPName
			) OPPM;
		
		IF OBJECT_ID('tempdb..#PaymentProviderDefault', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProviderDefault;
		END

		-- PaymentProviderDefault
		IF (@CurrentSystemType = 'Test' OR @CurrentSystemType = 'Dev')
		BEGIN
			PRINT('');PRINT('-Test/Dev Data ' + CAST(GETDATE() AS VARCHAR));
			PRINT('');PRINT('-INSERT INTO #PaymentProviderDefault ' + CAST(GETDATE() AS VARCHAR));
		END
		ELSE IF (@CurrentSystemType = 'Live')
		BEGIN
			PRINT('');PRINT('-Live Data ' + CAST(GETDATE() AS VARCHAR));
			PRINT('');PRINT('-INSERT INTO #PaymentProviderDefault ' + CAST(GETDATE() AS VARCHAR));
		END
		SELECT PPName, PPCode, PPShortCode
		INTO #PaymentProviderDefault
		FROM (
				SELECT @SecureTrading AS PPName, 'SecureTrading' AS PPCode, 'ST_O' AS PPShortCode, 'Live' AS [System]
				UNION SELECT @NetBanx AS PPName, '' AS PPCode, '' AS PPShortCode, 'Live' AS [System]
				UNION SELECT @BarclaysSmartPay AS PPName, 'Barclays Smart Pay' AS PPCode, 'B_SP' AS PPShortCode, 'Live' AS [System]
				UNION SELECT @SecureTrading AS PPName, 'SecureTrading' AS PPCode, 'ST_O' AS PPShortCode, 'Test' AS [System]
				UNION SELECT @NetBanx AS PPName, '' AS PPCode, '' AS PPShortCode, 'Test' AS [System]
				UNION SELECT @BarclaysSmartPay AS PPName, 'Barclays Smart Pay' AS PPCode, 'B_SP' AS PPShortCode, 'Test' AS [System]
			) OPPM
		WHERE [System] = @CurrentSystemType
		;
		
		IF OBJECT_ID('tempdb..#PaymentProviderCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProviderCredential;
		END
		-- #PaymentProviderCredential
		IF (@CurrentSystemType = 'Test' OR @CurrentSystemType = 'Dev')
		BEGIN
			PRINT('');PRINT('-Test/Dev Data ' + CAST(GETDATE() AS VARCHAR));
			PRINT('');PRINT('-INSERT INTO #PaymentProviderCredential ' + CAST(GETDATE() AS VARCHAR));
		END
		ELSE IF (@CurrentSystemType = 'Live')
		BEGIN
			PRINT('');PRINT('-Live ' + CAST(GETDATE() AS VARCHAR));
			PRINT('');PRINT('-INSERT INTO #PaymentProviderCredential ' + CAST(GETDATE() AS VARCHAR));
		END
		SELECT PPName, PPKey, PPValue
		INTO #PaymentProviderCredential
		FROM (
			SELECT @SecureTrading AS PPName, 'username' AS PPKey, 'Atlas2016@iam.org.uk' AS PPValue, 'Live' AS [System]
			UNION SELECT @SecureTrading AS PPName, 'password' AS PPKey, 'Atlas2016Payment' AS PPValue, 'Live' AS [System]
			UNION SELECT @SecureTrading AS PPName, 'sitereference' AS PPKey, 'pdsessex26545' AS PPValue, 'Live' AS [System]
			--
			UNION SELECT @BarclaysSmartPay AS PPName, 'username' AS PPKey, 'ws_935316@Company.GMPTE' AS PPValue, 'Live' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'password' AS PPKey, 'mGTctGdu+h3mzziXXm?g>6N&g' AS PPValue, 'Live' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'merchantAccount' AS PPKey, 'GMPTEINT' AS PPValue, 'Live' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'motoAccount' AS PPKey, 'GMPTEMOTO' AS PPValue, 'Live' AS [System]
			--
			UNION SELECT @SecureTrading AS PPName, 'username' AS PPKey, 'Atlas2016@iam.org.uk' AS PPValue, 'Test' AS [System]
			UNION SELECT @SecureTrading AS PPName, 'password' AS PPKey, 'Atlas2016Payment' AS PPValue, 'Test' AS [System]
			UNION SELECT @SecureTrading AS PPName, 'sitereference' AS PPKey, 'test_pdsessex35193' AS PPValue, 'Test' AS [System]
			--
			UNION SELECT @BarclaysSmartPay AS PPName, 'username' AS PPKey, 'ws_935316@Company.GMPTE' AS PPValue, 'Test' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'password' AS PPKey, 'mGTctGdu+h3mzziXXm?g>6N&g' AS PPValue, 'Test' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'merchantAccount' AS PPKey, 'GMPTEINT' AS PPValue, 'Test' AS [System]
			UNION SELECT @BarclaysSmartPay AS PPName, 'motoAccount' AS PPKey, 'GMPTEMOTO' AS PPValue, 'Test' AS [System]
			) PPC
		WHERE [System] = @CurrentSystemType
		;
	
		-- Update Table OrganisationPaymentProviderCredential
		IF OBJECT_ID('tempdb..#OrganisationPaymentProviderCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProviderCredential;
		END
	
		--Now Update Table OrganisationPaymentProvider
		BEGIN
			PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProvider ' + CAST(GETDATE() AS VARCHAR));
			SELECT OrganisationName, OPPM.PPName, PPCode, PPShortCode
			INTO #OrganisationPaymentProvider
			FROM #OrganisationPaymentProviderMatch OPPM
			INNER JOIN #PaymentProviderDefault PPC ON PPC.PPName = OPPM.PPName;
			
			PRINT('');PRINT('-INSERT INTO [OrganisationPaymentProvider] ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[OrganisationPaymentProvider] (OrganisationId, PaymentProviderId, ProviderCode, ShortCode)
			SELECT DISTINCT 
				O.Id AS OrganisationId
				, PP.Id AS PaymentProviderId
				, NewOPP.PPCode AS ProviderCode
				, NewOPP.PPShortCode AS ShortCode
			FROM Organisation O
			INNER JOIN #OrganisationPaymentProvider NewOPP ON O.[Name] LIKE '%' + NewOPP.OrganisationName + '%'
			INNER JOIN dbo.PaymentProvider PP ON PP.[Name] = NewOPP.PPName
			LEFT JOIN [dbo].[OrganisationPaymentProvider] OPP ON OPP.OrganisationId = O.Id
																AND OPP.PaymentProviderId = PP.Id
			WHERE OPP.Id IS NULL; --IE Not Already Inserted
			
			PRINT('');PRINT('-UPDATE [OrganisationPaymentProvider] ' + CAST(GETDATE() AS VARCHAR));
			UPDATE OPP
			SET OPP.ProviderCode = NewOPP.PPCode
			, OPP.ShortCode = NewOPP.PPShortCode
			FROM [dbo].[OrganisationPaymentProvider] OPP
			INNER JOIN Organisation O ON O.Id = OPP.OrganisationId
			INNER JOIN dbo.PaymentProvider PP ON PP.Id = OPP.PaymentProviderId
			INNER JOIN #OrganisationPaymentProvider NewOPP ON O.[Name] LIKE '%' + NewOPP.OrganisationName + '%'
															AND NewOPP.PPName = PP.[Name]
			WHERE OPP.ProviderCode != NewOPP.PPCode
			OR OPP.ShortCode != NewOPP.PPShortCode;
		END
		-----

		--Now Update Table OrganisationPaymentProviderCredential
		BEGIN
			PRINT('');PRINT('-INSERT INTO #OrganisationPaymentProviderCredential ' + CAST(GETDATE() AS VARCHAR));
			SELECT OrganisationName, OPPM.PPName, PPKey, PPValue
			INTO #OrganisationPaymentProviderCredential
			FROM #OrganisationPaymentProviderMatch OPPM
			INNER JOIN #PaymentProviderCredential PPD ON PPD.PPName = OPPM.PPName;
			
			PRINT('');PRINT('-INSERT INTO [OrganisationPaymentProviderCredential] ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[OrganisationPaymentProviderCredential] (OrganisationId, PaymentProviderId, [Key], [Value])
			SELECT DISTINCT 
				O.Id AS OrganisationId
				, PP.Id AS PaymentProviderId
				, NewOPPC.PPKey AS [Key]
				, NewOPPC.PPValue AS [Value]
			FROM Organisation O
			INNER JOIN #OrganisationPaymentProviderCredential NewOPPC ON O.[Name] LIKE '%' + NewOPPC.OrganisationName + '%'
			INNER JOIN dbo.PaymentProvider PP ON PP.[Name] = NewOPPC.PPName
			LEFT JOIN [dbo].[OrganisationPaymentProviderCredential] OPPC ON OPPC.OrganisationId = O.Id
																		AND OPPC.PaymentProviderId = PP.Id
																		AND OPPC.[Key] = NewOPPC.PPKey
			WHERE OPPC.Id IS NULL; --IE Not Already Inserted
			
			PRINT('');PRINT('-UPDATE [OrganisationPaymentProviderCredential] ' + CAST(GETDATE() AS VARCHAR));
			UPDATE OPPC
			SET OPPC.[Value] = NewOPPC.PPValue
			FROM [dbo].[OrganisationPaymentProviderCredential] OPPC
			INNER JOIN Organisation O ON O.Id = OPPC.OrganisationId
			INNER JOIN dbo.PaymentProvider PP ON PP.Id = OPPC.PaymentProviderId
			INNER JOIN #OrganisationPaymentProviderCredential NewOPPC ON O.[Name] LIKE '%' + NewOPPC.OrganisationName + '%'
																		AND NewOPPC.PPName = PP.[Name]
																		AND OPPC.[Key] = NewOPPC.PPKey
			WHERE OPPC.[Value] != NewOPPC.PPValue;
		END
		-----


		
	END

	

	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));
		IF OBJECT_ID('tempdb..#PaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProvider;
		END
		IF OBJECT_ID('tempdb..#OrganisationPaymentProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProvider;
		END
		IF OBJECT_ID('tempdb..#OrganisationPaymentProviderMatch', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProviderMatch;
		END
		IF OBJECT_ID('tempdb..#PaymentProviderDefault', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProviderDefault;
		END
		IF OBJECT_ID('tempdb..#PaymentProviderCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentProviderCredential;
		END
		IF OBJECT_ID('tempdb..#OrganisationPaymentProviderCredential', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #OrganisationPaymentProviderCredential;
		END
	

	END



	
PRINT('');PRINT('**Completed Script: "Migration_110.001_MigratePaymentProviderData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/


