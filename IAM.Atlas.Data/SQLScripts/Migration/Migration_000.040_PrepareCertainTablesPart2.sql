
/*
	Data Migration Script :- Prepare Certain Tables for Data Migration
	Script Name: Migration_000.040_PrepareCertainTablesPart2.sql
	Author: Robert Newnham
	Created: 29/06/2017
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Course or Client Data has been Migrated.

*/
	
/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_000.040_PrepareCertainTablesPart2.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	--This should be Run on the New Live Database


	
		/*
		 *	Create EmailTemplateCategory Table
		 */
		IF NOT OBJECT_ID('dbo._Migration_CourseOrganisation', 'U') IS NOT NULL
		BEGIN
			PRINT('');PRINT('*Create Course Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
		
			CREATE TABLE [dbo].[_Migration_CourseOrganisation](
				Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
				, OldCourseId			INT				NOT NULL	INDEX MIX_Migration_CourseOrganisationOldCourseId NONCLUSTERED
				, OldCourseReference	VARCHAR(100)	NULL		INDEX MIX_Migration_CourseOrganisationOldCourseReference NONCLUSTERED
				, OldOrgId				INT				NOT NULL	INDEX MIX_Migration_CourseOrganisationOldOrgId NONCLUSTERED
				, OldOrgName			VARCHAR(200)	NULL		INDEX MIX_Migration_CourseOrganisationOldOrgName NONCLUSTERED
				, DateAdded				DATETIME		NOT NULL	DEFAULT GETDATE()
			);

		END
		GO
		
		--Course
		BEGIN
			PRINT('');PRINT('*Update Course Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[_Migration_CourseOrganisation] (OldCourseId, OldCourseReference, OldOrgId, OldOrgName, DateAdded)
			SELECT DISTINCT 
				C.[crs_ID]		AS OldCourseId
				, C.[crs_refNo] AS OldCourseReference
				, O.org_id		AS OldOrgId
				, O.org_name	AS OldOrgName
				, GETDATE()		AS DateAdded
			FROM migration.tbl_Course C
			INNER JOIN migration.tbl_LU_CourseType OldCT				ON OldCT.ct_ID = C.crs_ct_id
			INNER JOIN migration.tbl_region_CourseType RCT				ON RCT.rct_ct_id = C.crs_ct_id
																		AND RCT.rct_rgn_id = C.crs_rgn_id
			INNER JOIN migration.tbl_Organisation_RegCrseType ORCT		ON ORCT.orc_rct_id = RCT.rct_id
			INNER JOIN migration.tbl_LU_Organisation O					ON O.org_id = ORCT.orc_org_id
			LEFT JOIN [dbo].[_Migration_CourseOrganisation] MCO			ON MCO.OldCourseId = C.[crs_ID]
																		AND MCO.OldOrgId = O.org_id
			WHERE MCO.Id IS NULL;
		END

		/**************************************************************************************************************************/
		
	
		/*
		 *	Create EmailTemplateCategory Table
		 */
		IF NOT OBJECT_ID('dbo._Migration_DriverClientOrganisation', 'U') IS NOT NULL
		BEGIN
			PRINT('');PRINT('*Create Course Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
		
			CREATE TABLE [dbo].[_Migration_DriverClientOrganisation](
				Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
				, OldDriverId			INT				NOT NULL	INDEX MIX_Migration_DriverClientOrganisationOldDriverId NONCLUSTERED
				, OldDriverName			VARCHAR(200)	NULL		INDEX MIX_Migration_DriverClientOrganisationOldDriverName NONCLUSTERED
				, OldOrgId				INT				NOT NULL	INDEX MIX_Migration_DriverClientOrganisationOldOrgId NONCLUSTERED
				, OldOrgName			VARCHAR(200)	NULL		INDEX MIX_Migration_DriverClientOrganisationOldOrgName NONCLUSTERED
				, DateAdded				DATETIME		NOT NULL	DEFAULT GETDATE()
			);

		END
		GO
		
		--Driver/Client
		BEGIN
			PRINT('');PRINT('*Update Driver/Client Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[_Migration_DriverClientOrganisation] (OldDriverId, OldDriverName, OldOrgId, OldOrgName, DateAdded)
			SELECT DISTINCT
				OldDR.dr_ID			AS OldDriverId
				, ISNULL(OldDR.[dr_title], '') 
					+ ' ' + ISNULL(OldDR.[dr_firstname], '') 
					+ ' ' + ISNULL(OldDR.[dr_lastname], '')	AS OldDriverName
				, OldOrg.org_id		AS OldOrgId
				, OldOrg.org_name	AS OldOrgName
				, GETDATE()			AS DateAdded
			FROM migration.tbl_Driver OldDR
			INNER JOIN migration.tbl_LU_Region OldR							ON OldR.rgn_id = OldDR.dr_provider_rgn_id
			INNER JOIN migration.[tbl_Region_CourseType] OldRCT				ON OldRCT.rct_rgn_id = OldDR.dr_provider_rgn_id
																			AND OldRCT.rct_ct_id = OldDR.dr_ct_id
			INNER JOIN migration.[tbl_Organisation_RegCrseType] OldORCT		ON OldORCT.orc_rct_id = OldRCT.rct_id
			INNER JOIN migration.tbl_LU_Organisation OldOrg					ON OldOrg.org_id = OldORCT.orc_org_id
			LEFT JOIN [dbo].[_Migration_DriverClientOrganisation] MDCO		ON MDCO.OldDriverId = OldDR.dr_ID
																			AND MDCO.OldOrgId = OldOrg.org_id
			WHERE MDCO.Id IS NULL;
		END


		/**************************************************************************************************************************/
		
		/*
		 *	Create EmailTemplateCategory Table
		 */
		IF NOT OBJECT_ID('dbo._Migration_InstructorOrganisation', 'U') IS NOT NULL
		BEGIN
			PRINT('');PRINT('*Create Trainer Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
		
			CREATE TABLE [dbo].[_Migration_InstructorOrganisation](
				Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
				, OldTrainerId			INT				NOT NULL	INDEX MIX_Migration_InstructorOrganisationOldTrainerId NONCLUSTERED
				, OldTrainerName		VARCHAR(200)	NULL		INDEX MIX_Migration_InstructorOrganisationOldTrainerName NONCLUSTERED
				, OldOrgId				INT				NOT NULL	INDEX MIX_Migration_InstructorOrganisationOldOrgId NONCLUSTERED
				, OldOrgName			VARCHAR(200)	NULL		INDEX MIX_Migration_InstructorOrganisationOldOrgName NONCLUSTERED
				, DateAdded				DATETIME		NOT NULL	DEFAULT GETDATE()
			);

		END
		GO
		
	
		--Trainer
		BEGIN
			PRINT('');PRINT('*Update Trainer Org Id Migration Table ' + CAST(GETDATE() AS VARCHAR));
			INSERT INTO [dbo].[_Migration_InstructorOrganisation] (OldTrainerId, OldTrainerName, OldOrgId, OldOrgName, DateAdded)
			SELECT DISTINCT 
				INS.ins_ID			AS OldTrainerId
				, INS.ins_name		AS OldTrainerName
				, O.org_id			AS OldOrgId
				, O.org_name		AS OldOrgName
				, GETDATE()			AS DateAdded
			FROM migration.[tbl_Instructor] INS
			INNER JOIN migration.tbl_region_CourseType RCT					ON RCT.rct_rgn_id = INS.[ins_rgn_id]
			INNER JOIN migration.tbl_Organisation_RegCrseType ORCT			ON ORCT.orc_rct_id = RCT.rct_id
			INNER JOIN migration.tbl_LU_Organisation O						ON O.org_id = ORCT.orc_org_id
			LEFT JOIN [dbo].[_Migration_InstructorOrganisation] MIO			ON MIO.OldTrainerId = INS.ins_ID
																			AND MIO.OldOrgId = O.org_id
			WHERE MIO.Id IS NULL;
		END
		
PRINT('');PRINT('**Completed Script: "Migration_000.040_PrepareCertainTablesPart2.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/



