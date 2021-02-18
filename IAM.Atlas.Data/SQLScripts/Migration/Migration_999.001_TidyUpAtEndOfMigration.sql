/*
	Data Migration Script :- End of Migration Database Tidy up
	Script Name: Migration_999.001_TidyUpAtEndOfMigration.sql

*/

PRINT('');PRINT('******************************************************************************************');
PRINT('');PRINT('**Running Script: "Migration_999.001_TidyUpAtEndOfMigration.sql" ' + CAST(GETDATE() AS VARCHAR));
DECLARE @OldAtlasDatabaseName VARCHAR(40) = 'Old_Atlas_20170615';

PRINT('');PRINT('*Drop Migration External Tables');
EXEC [dbo].[uspDropMigrationExternalTables]

PRINT('');PRINT('*Drop Link to Old Atlas Database: ' + @OldAtlasDatabaseName + ' ' + CAST(GETDATE() AS VARCHAR));
EXEC [dbo].[uspDropMigrationConnectionToOldAtlasDB]

PRINT('');PRINT('*Refresh Client Quick Search ' + CAST(GETDATE() AS VARCHAR));
EXEC [dbo].[uspRefreshClientQuickSearchData_RefreshAll]

PRINT('');PRINT('*Refresh Course Quick Search ' + CAST(GETDATE() AS VARCHAR));
EXEC [dbo].[usp_RefreshAllCourseQuickSearchData]

PRINT('');PRINT('*Ensure Default Admin Menu Assignments ' + CAST(GETDATE() AS VARCHAR));
EXEC [dbo].[uspEnsureDefaultAdminMenuAssignments]

PRINT('');PRINT('**Completed Script: "Migration_999.001_TidyUpAtEndOfMigration.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************');
