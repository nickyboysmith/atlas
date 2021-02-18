


/*
	Data Migration Script :- Migrate Linking Clients to Courses Data.
	Script Name: Migration_100.001_MigrateLinkingClientsToCoursesData.sql
	Author: Robert Newnham
	Created: 12/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Client or Course Data has been Migrated.

*/


/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_100.001_MigrateLinkingClientsToCoursesData.sql" ' + CAST(GETDATE() AS VARCHAR));

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

/**************************************************************************************************/
	--*Essential Reference Data
	BEGIN
		PRINT('');PRINT('*Populate Linking Clients to Courses Data Tables ' + CAST(GETDATE() AS VARCHAR));
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

	END

	BEGIN	
		PRINT('');PRINT('*Populate CourseClient ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[CourseClient] (
				CourseId
				, ClientId
				, DateAdded
				, AddedByUserId
				, EmailReminderSent
				, SMSReminderSent
				, TotalPaymentDue
				, [TotalPaymentMade]
				, [LastPaymentMadeDate]
				)
		SELECT DISTINCT
			COPI.CourseId			AS CourseId
			, CLPI.ClientId			AS ClientId
			, ISNULL(dr_date_latestBooking, GETDATE())	AS [DateAdded]
			, (CASE WHEN UPI.Id IS NULL OR UPI.UserId IS NULL
					THEN @MigrationUserId
					ELSE UPI.UserId END)		AS [AddedByUserId]
			, 'True'							AS [EmailReminderSent]
			, 'True'							AS [SMSReminderSent]
			, OldRCT.rct_courseFee						AS [TotalPaymentDue]
			, SUM(OldPay.[pm_amount])					AS [TotalPaymentMade]
			, MAX(OldPay.[pm_date])						AS [LastPaymentMadeDate]
		FROM [dbo].[_Migration_DriverClientOrganisation] M_DCO
		INNER JOIN [migration].[tbl_Driver] DRV							ON DRV.dr_ID = M_DCO.OldDriverId
		INNER JOIN migration.tbl_Driver_Data DRD						ON DRD.drd_dr_ID = DRV.dr_ID
		---------------------------------------------------------------------------------------------------------
		--INNER JOIN migration.tbl_LU_Region OldR							ON OldR.rgn_id = DRV.dr_provider_rgn_id
		--INNER JOIN migration.[tbl_Organisation_RegCrseType] OldORCT		ON OldORCT.orc_rct_id = OldRCT.rct_id
		INNER JOIN migration.tbl_LU_Organisation OldOrg					ON OldOrg.org_id = M_DCO.OldOrgId
		---------------------------------------------------------------------------------------------------------
		INNER JOIN [dbo].[ClientPreviousId] CLPI						ON CLPI.[PreviousClientId] = DRV.[dr_ID]
		INNER JOIN [dbo].[CoursePreviousId] COPI						ON COPI.PreviousCourseId = DRV.[dr_crs_ID]
		LEFT JOIN [dbo].[UserPreviousId] UPI							ON UPI.PreviousUserId = DRV.[dr_addedBy_usr_id]
		LEFT JOIN [dbo].[CourseClient] CC								ON CC.CourseId = COPI.CourseId
																		AND CC.ClientId = CLPI.ClientId
											
		LEFT JOIN migration.tbl_Payment OldPay							ON OldPay.pm_dr_id = DRV.dr_ID
																		AND OldPay.pm_crs_id = COPI.PreviousCourseId
		LEFT JOIN migration.tbl_Course OldC								ON OldC.crs_id = OldPay.pm_crs_id
		LEFT JOIN migration.[tbl_Region_CourseType] OldRCT				ON OldRCT.rct_rgn_id = DRV.dr_provider_rgn_id
																		AND OldRCT.rct_ct_id = OldC.crs_ct_id
		WHERE OldOrg.org_id = @MigrateDataForOldId
		AND CC.Id IS NULL
		GROUP BY COPI.CourseId
			, CLPI.ClientId
			, ISNULL(dr_date_latestBooking, GETDATE())
			, (CASE WHEN UPI.Id IS NULL OR UPI.UserId IS NULL
					THEN @MigrationUserId
					ELSE UPI.UserId END)
			, OldRCT.rct_courseFee
		;
	END

	BEGIN
		PRINT('');PRINT('*Populate CourseDateClientAttendance ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[CourseDateClientAttendance] (CourseDateId, CourseId, ClientId, CreatedByUserId, DateTimeAdded, TrainerId)
		SELECT DISTINCT
			CD.Id					AS CourseDateId
			, COPI.CourseId			AS CourseId
			, CPI.ClientId			AS ClientId
			, @MigrationUserId		AS CreatedByUserId
			, CD.[DateEnd]			AS DateTimeAdded
			, CT.TrainerId			AS TrainerId
		FROM dbo.ClientPreviousId CPI
		INNER JOIN [migration].[tbl_Driver] DR ON DR.dr_ID = CPI.PreviousClientId
		INNER JOIN dbo.CoursePreviousId COPI ON COPI.PreviousCourseId = DR.[dr_crs_ID]
		INNER JOIN dbo.CourseClient CC ON CC.CourseId = COPI.CourseId
										AND CC.ClientId = CPI.ClientId
		INNER JOIN dbo.CourseDate CD ON CD.CourseId = COPI.CourseId
		LEFT JOIN dbo.CourseTrainer CT ON CT.CourseId = COPI.CourseId
		LEFT JOIN [dbo].[CourseDateClientAttendance] CDCA ON CDCA.CourseDateId = CD.Id
															AND CDCA.CourseId = COPI.CourseId
															AND CDCA.ClientId = CPI.ClientId
		WHERE CD.DateStart < GETDATE()
		AND DR.[dr_didAttend] = 'True'
		AND CDCA.Id IS NULL;
		
		PRINT('');PRINT('*Populate CourseDateTrainerAttendance ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[CourseDateTrainerAttendance] (CourseDateId, CourseId, TrainerId, CreatedByUserId, DateTimeAdded)
		SELECT DISTINCT
			CD.Id					AS CourseDateId
			, COPI.CourseId			AS CourseId
			, CT.TrainerId			AS TrainerId
			, @MigrationUserId		AS CreatedByUserId
			, CD.[DateEnd]			AS DateTimeAdded
		FROM dbo.ClientPreviousId CPI
		INNER JOIN [migration].[tbl_Driver] DR ON DR.dr_ID = CPI.PreviousClientId
		INNER JOIN dbo.CoursePreviousId COPI ON COPI.PreviousCourseId = DR.[dr_crs_ID]
		INNER JOIN dbo.CourseClient CC ON CC.CourseId = COPI.CourseId
										AND CC.ClientId = CPI.ClientId
		INNER JOIN dbo.CourseDate CD ON CD.CourseId = COPI.CourseId
		INNER JOIN dbo.CourseTrainer CT ON CT.CourseId = COPI.CourseId
		LEFT JOIN [dbo].[CourseDateTrainerAttendance] CDTA ON CDTA.CourseDateId = CD.Id
															AND CDTA.CourseId = COPI.CourseId
															AND CDTA.TrainerId = CT.TrainerId
		WHERE CD.DateStart < GETDATE()
		AND DR.[dr_didAttend] = 'True'
		AND CDTA.Id IS NULL;

	END
	
	BEGIN
		PRINT('');PRINT('*Populate CourseDORSClient ' + CAST(GETDATE() AS VARCHAR));
		  INSERT INTO [dbo].[CourseDORSClient] (
			CourseId, ClientId, DateAdded, DORSNotified, DateDORSNotified, DORSAttendanceRef, DORSAttendanceStateIdentifier
			, NumberOfDORSNotificationAttempts, DateDORSNotificationAttempted, PaidInFull
			, OnlyPartPaymentMade, DatePaidInFull, TransferredToCourseId, TransferredFromCourseId, IsMysteryShopper)
		  SELECT 
			  CC.CourseId							AS [CourseId]
			  , CDD.ClientId						AS [ClientId]
			  , CDD.DateCreated						AS [DateAdded]
			  , 'True'								AS [DORSNotified]
			  , CDD.DateCreated						AS [DateDORSNotified]
			  , CDD.DORSAttendanceRef				AS [DORSAttendanceRef]
			  , DAS.[DORSAttendanceStateIdentifier]	AS [DORSAttendanceStateIdentifier]
			  , 0									AS [NumberOfDORSNotificationAttempts]
			  , NULL								AS [DateDORSNotificationAttempted]
			  , 'True'								AS [PaidInFull]
			  , 'False'								AS [OnlyPartPaymentMade]
			  , NULL								AS [DatePaidInFull]
			  , NULL								AS [TransferredToCourseId]
			  , NULL								AS [TransferredFromCourseId]
			  , 'False'								AS [IsMysteryShopper]
		  FROM dbo.CourseClient CC
		  INNER JOIN dbo.ClientDORSData CDD ON CDD.ClientId = CC.ClientId
		  LEFT JOIN dbo.DORSAttendanceState DAS ON DAS.Id = CDD.DORSAttendanceStateId
		  LEFT JOIN [dbo].[CourseDORSClient] CODD ON CODD.CourseId = CC.CourseId
													AND CODD.ClientId = CDD.ClientId
		 WHERE CODD.Id IS NULL;
	END

	BEGIN
		INSERT INTO [dbo].[CourseTypeCategory] (CourseTypeId, Disabled, Name)
		SELECT DISTINCT CT.Id AS CourseTypeId, 'False', '*None*'
		FROM [dbo].[CourseType] CT
		LEFT JOIN [dbo].[CourseTypeCategory] CTC ON CTC.CourseTypeId = CT.Id
												AND CTC.Name = '*None*'
		WHERE CTC.Id IS NULL;
	END

	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));

	END



	
PRINT('');PRINT('**Completed Script: "Migration_100.001_MigrateLinkingClientsToCoursesData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/