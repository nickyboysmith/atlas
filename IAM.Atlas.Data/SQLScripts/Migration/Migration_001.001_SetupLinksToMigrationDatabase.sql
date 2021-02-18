/*
	Data Migration Script :- Database Setup. Link Receiving Database to the Source Database.
	Script Name: Migration_001.001_SetupLinksToMigrationDatabase.sql

*/

PRINT('');PRINT('******************************************************************************************');
PRINT('');PRINT('**Running Script: "Migration_001.001_SetupLinksToMigrationDatabase.sql"');
DECLARE @OldAtlasDatabaseName VARCHAR(40) = 'Old_Atlas_20170716';

PRINT('');PRINT('*Setup Link to Old Atlas Database: ' + @OldAtlasDatabaseName);
EXEC dbo.uspCreateMigrationConnectionToOldAtlasDB @OldAtlasDatabaseName;

PRINT('');PRINT('*Create "Migration" Version of Old Atlas Tables (external Tables)');
EXEC dbo.uspCreateMigrationExternalTables;

PRINT('');PRINT('**Completed Script: "Migration_001.001_SetupLinksToMigrationDatabase.sql"');
PRINT('');PRINT('******************************************************************************************');
