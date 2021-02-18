/*
	Data Migration Script :- Fix Missing Data Issues
	Script Name: Migration_500.001_FixMissingDataIssues.sql

*/

PRINT('');PRINT('******************************************************************************************');
PRINT('');PRINT('**Running Script: "Migration_500.001_FixMissingDataIssues.sql" ' + CAST(GETDATE() AS VARCHAR));

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
	
	BEGIN
		PRINT('');PRINT('*Fix Missing Associated Session Number on Courses ' + CAST(GETDATE() AS VARCHAR));
		UPDATE CD
		SET CD.AssociatedSessionNumber = (CASE WHEN CAST(CD.DateStart AS Time) < (SELECT TOP 1 CAST(StartTime AS Time) FROM TrainingSession WHERE Title = 'PM')
												THEN (SELECT TOP 1 Number FROM TrainingSession TS1 WHERE Title = 'AM')
												WHEN CAST(CD.DateStart AS Time) >= (SELECT TOP 1 CAST(StartTime AS Time) FROM TrainingSession WHERE Title = 'PM')
												AND CAST(CD.DateStart AS Time) < (SELECT TOP 1 CAST(StartTime AS Time) FROM TrainingSession WHERE Title = 'EVE')
												THEN (SELECT TOP 1 Number FROM TrainingSession TS1 WHERE Title = 'PM')
												ELSE (SELECT TOP 1 Number FROM TrainingSession TS1 WHERE Title = 'EVE')
												END)
		FROM dbo.Course C
		INNER JOIN dbo.CourseDate CD ON CD.CourseId = C.Id
		WHERE CD.AssociatedSessionNumber IS NULL;
	END
	
	BEGIN
		PRINT('');PRINT('*Add Organisation to Dors Rotation List ' + CAST(GETDATE() AS VARCHAR));
		UPDATE dbo.DORSConnectionForRotation (DORSConnectionId, DateTimeOfLastTimeAsDefault, AddedByUserId, DateAdded)
		SELECT 
			DC.Id							AS DORSConnectionId
			, NULL							AS DateTimeOfLastTimeAsDefault
			, @MigrationUserId				AS AddedByUserId
			, GETDATE()						AS DateAdded
		FROM dbo.DORSConnection DC
		LEFT JOIN dbo.DORSConnectionForRotation DCFR ON DCFR.DORSConnectionId = DC.Id
		WHERE DC.OrganisationId = @MigrateDataForNewId
		AND DCFR.Id IS NULL;
	END

	BEGIN
		PRINT('');PRINT('*Populate ClientChangeLog ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[ClientChangeLog] (ClientId, ChangeType, ColumnName, PreviousValue, NewValue, Comment, DateCreated, AssociatedUserId)
		SELECT
			CLPI.ClientId				AS ClientId
			, (CASE WHEN DH.[dh_HistoryItem] IN ('DORS Integration', 'Course Confirmation Email', 'Course Completion Flag'
												, 'Client letter sent by email', 'Course Confirmation', 'Course Reminder Email'
												, 'Course Rejection', 'Difficulties reading/writing (by Client)', 'Netcall Payment (Agent)'
												, 'Netcall Payment (Client)', 'Perform DORS Check', 'DORS Attendance Status Checked'
												, 'DORS Intergration', 'DORS Status Checked (Red)', 'SMS Venue Change'
												)
						THEN [dh_HistoryItem]
					WHEN DH.[dh_HistoryItem] IN ( 'Client added', 'Client added through DORS lookup','Client Locked', 'Client Unlocked', '', '')
						THEN [dh_HistoryItem]
					WHEN DH.[dh_HistoryItem] IN ( 'Course')
						THEN 'Booked on ' + [dh_HistoryItem]
					ELSE [dh_HistoryItem] END)
										AS ChangeType
			, DH.[dh_HistoryItem]		ASColumnName
			, DH.dh_ChangedFrom			AS PreviousValue
			, DH.dh_ChangedTo			AS NewValue
			, (CASE WHEN DH.[dh_HistoryItem] IN ('DORS Integration', 'Course Confirmation Email', 'Course Completion Flag'
												, 'Client letter sent by email', 'Course Confirmation', 'Course Reminder Email'
												, 'Course Rejection', 'Difficulties reading/writing (by Client)', 'Netcall Payment (Agent)'
												, 'Netcall Payment (Client)', 'Perform DORS Check', 'DORS Attendance Status Checked'
												, 'DORS Intergration', 'DORS Status Checked (Red)', 'SMS Venue Change'
												)
						THEN DH.[dh_HistoryItem] + ': ' + DH.dh_ChangedTo
					WHEN DH.[dh_HistoryItem] IN ( 'Client added', 'Client added through DORS lookup','', '', '', '')
						THEN [dh_HistoryItem]
					WHEN DH.[dh_HistoryItem] IN ( 'Course')
						THEN 'Booked on ' + DH.[dh_HistoryItem] + ': ' + DH.dh_ChangedTo
					ELSE [dh_HistoryItem] + ' Changed From: "' + DH.dh_ChangedFrom + '" To: "' + DH.dh_ChangedTo + '"'
					END)
										AS Comment
			, DH.dh_Date				AS DateCreated
			, USPI.UserId				AS AssociatedUserId
		FROM dbo.ClientPreviousId CLPI
		INNER JOIN [migration].[tbl_Driver_History] DH	ON DH.[dh_dr_id] = CLPI.PreviousClientId
		LEFT JOIN dbo.UserPreviousId USPI				ON USPI.PreviousUserId = DH.dh_usr_id
		LEFT JOIN [dbo].[ClientChangeLog] CCL			ON CCL.ClientId = CLPI.ClientId
														AND CCL.DateCreated = DH.dh_Date
		AND CCL.Id IS NULL
		WHERE DH.[dh_HistoryItem] NOT IN ('ATLAS payment', 'Client online payment', 'Payment amount')
		ORDER BY  DH.dh_Date
	END

	BEGIN
		PRINT('');PRINT('*Populate ClientOrganisation For ReferringAuthority ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[ClientOrganisation] (ClientId, OrganisationId, DateAdded)
		SELECT DISTINCT
			CDD.ClientId								AS ClientId
			, RA.AssociatedOrganisationId				AS OrganisationId
			, MIN(ISNULL(CDD.DateCreated,GETDATE()))	AS DateAdded
		FROM dbo.ClientDORSData CDD
		INNER JOIN dbo.ReferringAuthority RA			ON RA.Id= CDD.ReferringAuthorityId
		LEFT JOIN [dbo].[ClientOrganisation] CO			ON CO.ClientId = CDD.ClientId
														AND CO.OrganisationId = RA.AssociatedOrganisationId
		WHERE CO.Id IS NULL
		GROUP BY CDD.ClientId, RA.AssociatedOrganisationId; --User Group By As the Client may be on ClientDORSData Multiple Times with different Dates

		
		PRINT('');PRINT('*Populate ReferringAuthorityClient ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[ReferringAuthorityClient] (ReferringAuthorityId, ClientId)
		SELECT DISTINCT
			CDD.ReferringAuthorityId					AS ReferringAuthorityId
			, CDD.ClientId								AS ClientId
		FROM dbo.ClientDORSData CDD
		LEFT JOIN [dbo].[ReferringAuthorityClient] RAC			ON RAC.ClientId = CDD.ClientId
																AND RAC.ReferringAuthorityId = CDD.ReferringAuthorityId
		WHERE RAC.Id IS NULL;

		
		PRINT('');PRINT('*Populate ReferringAuthorityUser ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.ReferringAuthorityUser (ReferringAuthorityId, UserId, DateAdded, AddedByUserId) 
		SELECT DISTINCT
			RA.Id							AS ReferringAuthorityId
			, OU.UserId						AS UserId
			, GETDATE()						AS DateAdded
			, dbo.udfGetSystemUserId()		AS AddedByUserId
		FROM dbo.OrganisationUser OU
		INNER JOIN [dbo].[ReferringAuthority] RA		ON RA.[AssociatedOrganisationId] = OU.[OrganisationId]
		LEFT JOIN dbo.ReferringAuthorityUser RAU		ON RAU.[ReferringAuthorityId] = RA.Id
														AND RAU.UserId = OU.UserId
		WHERE RAU.Id IS NULL;

		
		PRINT('');PRINT('*Populate Missing ReferringAuthority For Clients ' + CAST(GETDATE() AS VARCHAR));
		UPDATE CDD
		SET CDD.ReferringAuthorityId = RA.Id
		FROM [dbo].[ClientDORSData] CDD
		INNER JOIN [dbo].[ClientPreviousId] CPI ON CPI.ClientId = CDD.ClientId
		INNER JOIN migration.tbl_LU_Organisation OldO ON OldO.org_id = CPI.PreviousReferrerOrgId
		INNER JOIN dbo.ReferringAuthority RA ON RA.DORSForceId = OldO.org_dors_for_id
		WHERE CDD.ReferringAuthorityId IS NULL;

	END

PRINT('');PRINT('**Completed Script: "Migration_500.001_FixMissingDataIssues.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************');
