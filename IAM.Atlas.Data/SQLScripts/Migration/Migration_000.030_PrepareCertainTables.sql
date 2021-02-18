
/*
	Data Migration Script :- Prepare Certain Tables for Data Migration
	Script Name: Migration_000.030_PrepareCertainTables.sql
	Author: Robert Newnham
	Created: 29/06/2017
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Course or Client Data has been Migrated.

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_000.030_PrepareCertainTables.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	--This should be Run on the Migration Database

	ALTER TABLE [migration].[tbl_Course]
	ALTER COLUMN [crs_notes_register] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Course]
	ALTER COLUMN [crs_notes_instructor] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Driver_Data]
	ALTER COLUMN [drd_address] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Instructor]
	ALTER COLUMN [ins_address] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_LU_Venue]
	ALTER COLUMN [vnu_directions] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_WebServiceUsers]
	ALTER COLUMN [web_pgp_publicKey] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_instructorsNotice] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_instructorsBooked] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_instructorsBooked] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_instructorsRemoved] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_ClientsNotice] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_ReferrersNotice] VARCHAR(8000);
	
	--ALTER TABLE [migration].[tbl_Region_CourseType]
	--ALTER COLUMN [rct_email_DriverContent] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_VenueContent] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_VenueContent] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_VenueContent] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_email_ClientCourseContent] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_coursenotesfields] VARCHAR(8000);

	--ALTER TABLE [migration].[tbl_Region_CourseType]
	--ALTER COLUMN [rct_register_freeText] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_smsCourseReminderText] VARCHAR(8000);
	
	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_smsCourseReminderText] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_smsCourseConfirmationText] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_lettersByEmailBody] VARCHAR(8000);

	ALTER TABLE [migration].[tbl_Region_CourseType]
	ALTER COLUMN [rct_emailCourseReminderText] VARCHAR(8000);



	--Create Indexes for Migration
	
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Paymentpm_dr_id' 
			AND object_id = OBJECT_ID('migration.tbl_Payment'))
	BEGIN
		DROP INDEX [MIX_tbl_Paymentpm_dr_id] ON [migration].[tbl_Payment];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Paymentpm_dr_id] ON [migration].[tbl_Payment]
	(
		[pm_dr_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Paymentpm_crs_id' 
			AND object_id = OBJECT_ID('migration.tbl_Payment'))
	BEGIN
		DROP INDEX [MIX_tbl_Paymentpm_crs_id] ON [migration].[tbl_Payment];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Paymentpm_crs_id] ON [migration].[tbl_Payment]
	(
		[pm_crs_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Paymentpm_pmm_id' 
			AND object_id = OBJECT_ID('migration.tbl_Payment'))
	BEGIN
		DROP INDEX [MIX_tbl_Paymentpm_pmm_id] ON [migration].[tbl_Payment];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Paymentpm_pmm_id] ON [migration].[tbl_Payment]
	(
		[pm_pmm_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Course_Historych_crs_id' 
			AND object_id = OBJECT_ID('migration.tbl_Course_History'))
	BEGIN
		DROP INDEX [MIX_tbl_Course_Historych_crs_id] ON [migration].[tbl_Course_History];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Course_Historych_crs_id] ON [migration].[tbl_Course_History]
	(
		[ch_crs_id] ASC
	) ;
	/************************************************************************************/
		

	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Driver_Documents_drdoc_dr_id' 
			AND object_id = OBJECT_ID('migration.tbl_Driver_Documents'))
	BEGIN
		DROP INDEX [MIX_tbl_Driver_Documents_drdoc_dr_id] ON [migration].[tbl_Driver_Documents];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Driver_Documents_drdoc_dr_id] ON [migration].[tbl_Driver_Documents]
	(
		[drdoc_dr_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Driver_dr_ID' 
			AND object_id = OBJECT_ID('migration.tbl_Driver'))
	BEGIN
		DROP INDEX [MIX_tbl_Driver_dr_ID] ON [migration].[tbl_Driver];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Driver_dr_ID] ON [migration].[tbl_Driver]
	(
		[dr_ID] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Region_CourseType_rct_rgn_id' 
			AND object_id = OBJECT_ID('migration.tbl_Region_CourseType'))
	BEGIN
		DROP INDEX [MIX_tbl_Region_CourseType_rct_rgn_id] ON [migration].[tbl_Region_CourseType];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Region_CourseType_rct_rgn_id] ON [migration].[tbl_Region_CourseType]
	(
		[rct_rgn_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_LU_Region_rgn_id' 
			AND object_id = OBJECT_ID('migration.tbl_LU_Region'))
	BEGIN
		DROP INDEX [MIX_tbl_LU_Region_rgn_id] ON [migration].[tbl_LU_Region];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_LU_Region_rgn_id] ON [migration].[tbl_LU_Region]
	(
		[rgn_id] ASC
	) ;
	/************************************************************************************/
			
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_Organisation_RegCrseType_orc_rct_id' 
			AND object_id = OBJECT_ID('migration.tbl_Organisation_RegCrseType'))
	BEGIN
		DROP INDEX [MIX_tbl_Organisation_RegCrseType_orc_rct_id] ON [migration].[tbl_Organisation_RegCrseType];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_Organisation_RegCrseType_orc_rct_id] ON [migration].[tbl_Organisation_RegCrseType]
	(
		[orc_rct_id] ASC
	) ;
	/************************************************************************************/
		
	--Drop Index if Exists
	IF EXISTS(SELECT * 
			FROM sys.indexes 
			WHERE name='MIX_tbl_LU_Organisation_org_id' 
			AND object_id = OBJECT_ID('migration.tbl_LU_Organisation'))
	BEGIN
		DROP INDEX [MIX_tbl_LU_Organisation_org_id] ON [migration].[tbl_LU_Organisation];
	END
		
	--Now Create Index
	CREATE NONCLUSTERED INDEX [MIX_tbl_LU_Organisation_org_id] ON [migration].[tbl_LU_Organisation]
	(
		[org_id] ASC
	) ;
	/************************************************************************************/
		
	--IF NOT EXISTS(SELECT 1 FROM sys.columns 
	--WHERE Name = N'dr_currentOrgId'
	--AND Object_ID = Object_ID(N'migration.tbl_Driver'))
	--BEGIN
	--	-- Column Does Not Exist Create It
	--	PRINT('');PRINT('*Create Driver Org Id ' + CAST(GETDATE() AS VARCHAR));

	--	ALTER TABLE migration.tbl_Driver
	--	ADD dr_currentOrgId INT NULL;

	--END

	--IF NOT EXISTS(SELECT 1 FROM sys.columns 
	--WHERE Name = N'crs_currentOrgId'
	--AND Object_ID = Object_ID(N'migration.tbl_Course'))
	--BEGIN
	--	-- Column Does Not Exist Create It
	--	PRINT('');PRINT('*Create Course Org Id ' + CAST(GETDATE() AS VARCHAR));

	--	ALTER TABLE migration.tbl_Course
	--	ADD crs_currentOrgId INT NULL;
	--END
	
	--IF NOT EXISTS(SELECT 1 FROM sys.columns 
	--WHERE Name = N'ins_currentOrgId'
	--AND Object_ID = Object_ID(N'migration.tbl_Instructor'))
	--BEGIN
	--	-- Column Does Not Exist Create It
	--	PRINT('');PRINT('*Create Instructor Org Id ' + CAST(GETDATE() AS VARCHAR));

	--	ALTER TABLE migration.tbl_Instructor
	--	ADD ins_currentOrgId INT NULL;
	--END

	--GO
	
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='MIX_tbl_Instructorins_currentOrgId' 
	--		AND object_id = OBJECT_ID('migration.tbl_Instructor'))
	--BEGIN
	--	PRINT('');PRINT('*Create Index for Course Org Id ' + CAST(GETDATE() AS VARCHAR));
	--	--Create Index
	--	CREATE NONCLUSTERED INDEX [MIX_tbl_Instructorins_currentOrgId] ON [migration].[tbl_Instructor]
	--	(
	--		[ins_currentOrgId] ASC
	--	) ;
	--END
		
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='MIX_tbl_Coursecrs_currentOrgId' 
	--		AND object_id = OBJECT_ID('migration.tbl_Course'))
	--BEGIN
	--	PRINT('');PRINT('*Create Index for Course Org Id ' + CAST(GETDATE() AS VARCHAR));
	--	--Create Index
	--	CREATE NONCLUSTERED INDEX [MIX_tbl_Coursecrs_currentOrgId] ON [migration].[tbl_Course]
	--	(
	--		[crs_currentOrgId] ASC
	--	) ;
	--END
		
	--IF EXISTS(SELECT * 
	--		FROM sys.indexes 
	--		WHERE name='MIX_tbl_Driverdr_currentOrgId' 
	--		AND object_id = OBJECT_ID('migration.tbl_Driver'))
	--BEGIN
	--	PRINT('');PRINT('*Create Index for Driver/Client Org Id ' + CAST(GETDATE() AS VARCHAR));
	--	--Create Index
	--	CREATE NONCLUSTERED INDEX [MIX_tbl_Driverdr_currentOrgId] ON [migration].[tbl_Driver]
	--	(
	--		[dr_currentOrgId] ASC
	--	) ;
	--END
		
	/**************************************************************************************************************************/
	
PRINT('');PRINT('**Completed Script: "Migration_000.030_PrepareCertainTables.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/


