

/*
	Data Migration Script :- Migrate Payment Data.
	Script Name: Migration_120.001_MigratePaymentData.sql
	Author: Robert Newnham
	Created: 15/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Course Data has been Migrated.

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_120.001_MigratePaymentData.sql" - ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

-- Add a Temp Column to the Client Table. This will be removed further down this Script
BEGIN
	ALTER TABLE dbo.Payment
	ADD TempFieldPreviousPaymentId int NULL;
END
GO

-- Add a Temp Column to the Note Table. This will be removed further down this Script
BEGIN
	ALTER TABLE dbo.Note
	ADD TempPaymentId int NULL;
END
GO

	--PRINT('');PRINT('*Create Temp Column Indexes - ' + CAST(GETDATE() AS VARCHAR));
	----Drop Index if Exists
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='IX_PaymentTempFieldPreviousPaymentId' 
	--		AND object_id = OBJECT_ID('Payment'))
	--BEGIN
	--	DROP INDEX [IX_PaymentTempFieldPreviousPaymentId] ON [dbo].[Payment];
	--END
		
	----Now Create Index
	--CREATE NONCLUSTERED INDEX [IX_PaymentTempFieldPreviousPaymentId] ON [dbo].[Payment]
	--(
	--	[TempFieldPreviousPaymentId] DESC
	--);
	----Drop Index if Exists
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='IX_NoteTempPaymentId' 
	--		AND object_id = OBJECT_ID('Note'))
	--BEGIN
	--	DROP INDEX [IX_NoteTempPaymentId] ON [dbo].[Note];
	--END
		
	----Now Create Index
	--CREATE NONCLUSTERED INDEX [IX_NoteTempPaymentId] ON [dbo].[Note]
	--(
	--	[TempPaymentId] DESC
	--);
/**************************************************************************************************/

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

	PRINT('');PRINT('*Migrate Payment Data Tables - ' + CAST(GETDATE() AS VARCHAR));

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
	
	----POPULATE PaymentProvider
	--BEGIN
	--	PRINT('');PRINT('*Populate PaymentProvider - ' + CAST(GETDATE() AS VARCHAR));
	--	INSERT INTO dbo.PaymentProvider (Name, ProviderCode, ShortCode, OrganisationId)
	--	SELECT DISTINCT OldPP.pp_name AS Name
	--					, OldPP.pp_providerCode AS ProviderCode
	--					, OldPP.pp_shortCode AS ShortCode
	--					, O.Id AS OrganisationId
	--	FROM migration.tbl_LU_PaymentProvider OldPP
	--	, dbo.Organisation O
	--	WHERE NOT EXISTS (SELECT * 
	--						FROM dbo.PaymentProvider NewPP 
	--						WHERE NewPP.Name = OldPP.pp_name
	--						AND ISNULL(NewPP.ProviderCode,'') = ISNULL(OldPP.pp_providerCode,'')
	--						AND ISNULL(NewPP.ShortCode,'') = ISNULL(OldPP.pp_shortCode,'')
	--						AND NewPP.OrganisationId = O.Id
	--						)
	--	ORDER BY O.Id
	--END
	/**************************************************************************************************/

	--POPULATE PaymentMethod
	BEGIN
		PRINT('');PRINT('*Populate PaymentMethod - ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.PaymentMethod (
			[Name]
			, [Description]
			, Code
			, OrganisationId
			, [Disabled]
			)
		SELECT DISTINCT
			pmm_description AS [Name]
			, pmm_description AS [Description]
			, pmm_code AS Code
			, NewOrg.Id AS OrganisationId
			, 'False' AS [Disabled]
		FROM migration.tbl_LU_PaymentMethod OldPM
		, ([migration].tbl_LU_Organisation OldOrg
			INNER JOIN [dbo].Organisation NewOrg ON NewOrg.[Name] = OldOrg.org_name )
		WHERE OldOrg.org_id = @MigrateDataForOldId
		AND NOT EXISTS (SELECT * 
							FROM dbo.PaymentMethod NewPM
							WHERE NewPM.[Name] = OldPM.pmm_description
							AND NewPM.OrganisationId = NewOrg.Id
							)
	END
	/**************************************************************************************************/

	--*POPULATE Payment
	PRINT('');PRINT('*POPULATE Payment - ' + CAST(GETDATE() AS VARCHAR));
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
			PRINT('');PRINT('-Create PaymentDetails Temp Table - ' + CAST(GETDATE() AS VARCHAR));
			SELECT
				OldPay1.pm_id					AS OldPayId
				, OldPay1.pm_date				AS DateCreated
				, OldPay1.pm_date				AS TransactionDate
				, OldPay1.pm_amount				AS Amount
				, OldPay1.pm_receiptNumber		AS ReceiptNumber
				, OldPay1.pm_authCode			AS AuthCode
				, OldPay1.pm_pmm_id				AS OldPayMethodId
				, NewPM1.Id						AS NewPayMethodId
				, OldPay1.pm_usr_id				AS OldUserId
				, NewUp1.UserId					AS NewUserId
				, CO.OrganisationId				AS NewOrganisationId
				, OldPay1.pm_dr_id				AS OldClientId
				, NewCP1.ClientId				AS NewClientId
				, OldPay1.[pm_crs_id]			AS OldCourseId
				, NewCOP1.CourseId				AS NewCourseId
				, (CAST(
						(CASE WHEN OldPM1.pmm_description LIKE ' Card' 
								THEN 'True' 
								ELSE 'False' 
						END) 
						AS BIT))				AS CardPayment
				, 'Migrated: ' + CONVERT(varchar(23), GETDATE(), 121) AS Comments
				, OldPay1.[pm_isnetcall]		AS NetcallPayment
			INTO #PaymentDetails
			FROM migration.tbl_Payment OldPay1
			INNER JOIN dbo.ClientPreviousId NewCP1			ON NewCP1.PreviousClientId = OldPay1.pm_dr_id
			INNER JOIN [dbo].[ClientOrganisation] CO		ON CO.ClientId = NewCP1.ClientId
			LEFT JOIN [dbo].[CoursePreviousId] NewCOP1			ON NewCOP1.PreviousCourseId = OldPay1.[pm_crs_id]
			LEFT JOIN migration.tbl_LU_PaymentMethod AS OldPM1	ON OldPM1.pmm_id = OldPay1.pm_pmm_id
			LEFT JOIN dbo.PaymentMethod NewPM1					ON NewPM1.OrganisationId = CO.OrganisationId
																AND NewPM1.[Name] = OldPM1.pmm_description
			LEFT JOIN migration.tbl_Users OldU1					ON OldU1.usr_ID = OldPay1.pm_usr_id
			LEFT JOIN dbo.UserPreviousId NewUp1					ON NewUp1.PreviousUserId = OldPay1.pm_usr_id
			LEFT JOIN dbo.OrganisationUser NewO1				ON NewO1.UserId = NewUp1.UserId
			WHERE CO.OrganisationId = @MigrateDataForNewId
			OR ISNULL(NewO1.OrganisationId,-1) = @MigrateDataForNewId
			;
		END --Create PaymentDetails Temp Table
		
		INSERT INTO Payment Table
		BEGIN
			PRINT('');PRINT('-INSERT INTO Payment Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Payment (
											DateCreated
											, TransactionDate
											, Amount
											, PaymentTypeId
											, PaymentMethodId
											, ReceiptNumber
											, AuthCode
											, CreatedByUserId
											, CardPayment
											, Refund
											, NetcallPayment
											, TempFieldPreviousPaymentId
											)
			SELECT 
					PD.DateCreated				AS DateCreated
					, PD.TransactionDate		AS TransactionDate
					, PD.Amount					AS Amount
					, NULL						AS PaymentTypeId
					, PD.NewPayMethodId			AS PaymentMethodId
					, PD.ReceiptNumber			AS ReceiptNumber
					, PD.AuthCode				AS AuthCode
					, (CASE WHEN PD.NewUserId IS NULL THEN @UnknownUserId ELSE PD.NewUserId END)	AS CreatedByUserId
					, PD.CardPayment																AS CardPayment
					, (CASE WHEN PD.Amount < 0 THEN 'True' ELSE 'False' END)						AS Refund
					, PD.NetcallPayment																AS NetcallPayment
					, PD.OldPayId																	AS TempFieldPreviousPaymentId
			FROM #PaymentDetails PD
			LEFT JOIN dbo.PaymentPreviousId PPI On PPI.PreviousPaymentId = OldPayId
			WHERE PPI.Id IS NULL
			;

		END --INSERT INTO Payment Table
		
		--INSERT INTO PreviousPaymentId Table
		BEGIN
			PRINT('');PRINT('INSERT INTO PreviousPaymentId Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.PaymentPreviousId (PaymentId, PreviousPaymentId)
			SELECT P.Id AS PaymentId, P.TempFieldPreviousPaymentId AS PreviousPaymentId 
			FROM dbo.Payment P
			LEFT JOIN dbo.PaymentPreviousId PPI On PPI.PreviousPaymentId = P.TempFieldPreviousPaymentId
			WHERE PPI.Id IS NULL
			AND P.TempFieldPreviousPaymentId IS NOT NULL
			;
		END --INSERT INTO PreviousPaymentId Table
		
		--Incase Some bits of data Were missed in first round do an Update
		BEGIN
			PRINT('');PRINT('-UPDATE Payment Table - ' + CAST(GETDATE() AS VARCHAR));
			UPDATE P
				SET P.CardPayment = PD.CardPayment
				, P.Refund = (CASE WHEN PD.Amount < 0 THEN 'True' ELSE 'False' END)
				, P.NetcallPayment = PD.NetcallPayment
			FROM #PaymentDetails PD
			INNER JOIN dbo.PaymentPreviousId PPI On PPI.PreviousPaymentId = PreviousPaymentId
			INNER JOIN [dbo].[Payment] P ON P.Id = PPI.PaymentId

		END --Incase Some bits of data Were missed in first round do an Update
		
		--INSERT INTO ClientPayment Table
		BEGIN
			PRINT('');PRINT('INSERT INTO ClientPayment Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPayment (ClientId, PaymentId, AddedByUserId)
			SELECT DISTINCT
				PD.NewClientId AS ClientId
				, P.Id AS PaymentId
				, (CASE WHEN PD.NewUserId IS NULL THEN @UnknownUserId ELSE PD.NewUserId END)	AS AddedByUserId
			FROM  #PaymentDetails PD
			INNER JOIN dbo.PaymentPreviousId PPI ON PPI.PreviousPaymentId = PD.OldPayId
			INNER JOIN dbo.Payment P ON P.Id = PPI.PaymentId
			WHERE PD.NewClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM dbo.ClientPayment CP
								WHERE CP.ClientId = PD.NewClientId
								AND CP.PaymentId = P.Id)
		END --INSERT INTO ClientPayment Table
		
		--INSERT INTO CourseClientPayment Table
		BEGIN
			PRINT('');PRINT('INSERT INTO CourseClientPayment Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[CourseClientPayment] (CourseId, ClientId, PaymentId, AddedByUserId)
			SELECT DISTINCT
				PD.NewCourseId AS CourseId
				, PD.NewClientId AS ClientId
				, P.Id AS PaymentId
				, (CASE WHEN PD.NewUserId IS NULL THEN @UnknownUserId ELSE PD.NewUserId END)	AS AddedByUserId
			FROM  #PaymentDetails PD
			INNER JOIN dbo.PaymentPreviousId PPI ON PPI.PreviousPaymentId = PD.OldPayId
			INNER JOIN dbo.Payment P ON P.Id = PPI.PaymentId
			WHERE PD.NewCourseId IS NOT NULL
			AND PD.NewClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM dbo.CourseClientPayment CCP
								WHERE CCP.CourseId = PD.NewCourseId
								AND CCP.ClientId = PD.NewClientId
								AND CCP.PaymentId = P.Id)
		END --INSERT INTO CourseClientPayment Table

		--INSERT INTO ClientPaymentPreviousClientId Table
		BEGIN
			PRINT('');PRINT('INSERT INTO ClientPaymentPreviousClientId Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPaymentPreviousClientId (PaymentId, ClientId, PreviousClientId)
			SELECT DISTINCT
				P.Id AS PaymentId
				, PD.NewClientId AS ClientId
				, PD.OldClientId AS PreviousClientId
			FROM  #PaymentDetails PD
			INNER JOIN dbo.PaymentPreviousId PPI ON PPI.PreviousPaymentId = PD.OldPayId
			INNER JOIN dbo.Payment P ON P.Id = PPI.PaymentId
			WHERE PD.OldClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM dbo.ClientPaymentPreviousClientId PCI
								WHERE PCI.PaymentId = P.Id
								AND PCI.ClientId = PD.NewClientId
								AND PCI.PreviousClientId = PD.OldClientId
								)
		END --INSERT INTO ClientPaymentPreviousClientId Table
		
		--INSERT INTO Client Payment Note Tables
		BEGIN
			PRINT('');PRINT('INSERT INTO Client Payment Note Tables - ' + CAST(GETDATE() AS VARCHAR));
		
			--Create Temp Table #PaymentNotes
			PRINT('');PRINT('Create Temp Table #PaymentNotes - ' + CAST(GETDATE() AS VARCHAR));
			SELECT PPI.PaymentId AS PaymentId
				, PD.Comments AS Note
				, NT.Id AS NoteTypeId
				, @MigrationUserId AS UserId
				, PD.NewClientId AS ClientId
			INTO #PaymentNotes
			FROM #PaymentDetails PD
			INNER JOIN dbo.PaymentPreviousId PPI ON PPI.PreviousPaymentId = PD.OldPayId
			INNER JOIN dbo.Payment P ON P.Id = PPI.PaymentId
			INNER JOIN dbo.NoteType NT ON NT.Name = 'General'
			WHERE LEN(PD.Comments) > 0;
			
			--INSERT INTO Note Table
			PRINT('');PRINT('INSERT INTO Note Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.Note (Note, DateCreated, CreatedByUserId, NoteTypeId, TempPaymentId)
			SELECT PN.Note
					, GETDATE() AS DateCreated
					, (CASE WHEN PN.UserId IS NULL THEN @MigrationUserId ELSE PN.UserId END) AS CreatedByUserId
					, PN.NoteTypeId
					, PN.PaymentId AS TempPaymentId
			FROM #PaymentNotes PN
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.Note N
								WHERE N.TempPaymentId = PN.PaymentId
								)
			;
			
			--INSERT INTO ClientPaymentNote Table
			PRINT('');PRINT('INSERT INTO ClientPaymentNote Table - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.ClientPaymentNote (ClientId, PaymentId, NoteId)
			SELECT PN.ClientId, PN.PaymentId, N.Id AS NoteId
			FROM dbo.Note N
			INNER JOIN #PaymentNotes PN ON PN.PaymentId = N.TempPaymentId
			WHERE N.TempPaymentId IS NOT NULL
			AND PN.ClientId IS NOT NULL
			AND NOT EXISTS (SELECT * 
								FROM dbo.ClientPaymentNote CPN
								WHERE CPN.ClientId = PN.ClientId
								AND CPN.PaymentId = PN.PaymentId
								AND CPN.NoteId = N.Id
								)
			;
			
		END --INSERT INTO Client Payment Note Tables
		
		BEGIN
			PRINT('');PRINT('INSERT INTO CourseClientPayment Table Missing Payments - ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO dbo.CourseClientPayment (CourseId, ClientId, PaymentId, AddedByUserId)
			SELECT DISTINCT
				CCL.CourseId				AS CourseId
				, CL.Id						AS ClientId
				, CLP.PaymentId				AS PaymentId
				, P.CreatedByUserId			AS AddedByUserId
			FROM dbo.Client CL
			INNER JOIN dbo.ClientPayment CLP ON CLP.ClientId = CL.Id
			INNER JOIN dbo.Payment P ON P.Id = CLP.PaymentId
			INNER JOIN dbo.CourseClient CCL ON CCL.ClientId = CL.Id
			LEFT JOIN dbo.CourseClientPayment CCLP ON CCLP.CourseId = CCL.CourseId AND CCLP.ClientId = CL.Id
			WHERE CCLP.Id IS NULL
			AND P.Amount = CCL.TotalPaymentDue
			AND CCL.TotalPaymentMade IS NULL
			;
		END
	END
	
	/***************************************************************************************************/
	

	BEGIN
	
		PRINT('');PRINT('*Tidy Up - ' + CAST(GETDATE() AS VARCHAR));
		
		PRINT('');PRINT('*Remove Temp Tables - ' + CAST(GETDATE() AS VARCHAR));
		IF OBJECT_ID('tempdb..#PaymentDetails', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentDetails;
		END

		IF OBJECT_ID('tempdb..#PaymentNotes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #PaymentNotes;
		END
		
	END
	
	PRINT('');PRINT('*Remove the Temp Column Indexes - ' + CAST(GETDATE() AS VARCHAR));
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='IX_PaymentTempFieldPreviousPaymentId' 
			AND object_id = OBJECT_ID('Payment'))
	BEGIN
		DROP INDEX [IX_PaymentTempFieldPreviousPaymentId] ON [dbo].[Payment];
	END
		
	----Drop Index if Exists
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='IX_NoteTempPaymentId' 
	--		AND object_id = OBJECT_ID('Note'))
	--BEGIN
	--	DROP INDEX [IX_NoteTempPaymentId] ON [dbo].[Note];
	--END
		
	PRINT('');PRINT('*Remove the Temp Column on the Payment Table - ' + CAST(GETDATE() AS VARCHAR));
	-- Remove the Temp Column on the Payment Table
	BEGIN
		ALTER TABLE dbo.Payment
		DROP COLUMN TempFieldPreviousPaymentId;
	END
	GO
		
	PRINT('');PRINT('*Remove the Temp Column on the Note Table - ' + CAST(GETDATE() AS VARCHAR));
	-- Remove the Temp Column on the Note Table
	BEGIN
		ALTER TABLE dbo.Note
		DROP COLUMN TempPaymentId;
	END
	GO





	
PRINT('');PRINT('**Completed Script: "Migration_120.001_MigratePaymentData.sql" - ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/


