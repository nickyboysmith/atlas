



--Create Indexes for Migration



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
		