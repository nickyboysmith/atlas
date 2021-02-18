

/*
	Data Migration Script :- Setup Required Data Before Migration Begins.
	Script Name: Migration_005.001_SetupRequiredDataBeforeMigrationBegins.sql
	Author: Robert Newnham
	Created: 06/08/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. This Script Should be Run Before any Reference Data has been Migrated.
	NB. This Script Should be Run Before any Client or Course Data has been Migrated.

*/


/******************* Migrate DORS Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_005.001_SetupRequiredDataBeforeMigrationBegins.sql"');

/**************************************************************************************************/
	--*Essential Reference Data
	BEGIN
		PRINT('');PRINT('*Setup Required Data Before Migration Begins');

	END
	
	--*Create 'UnknownUser' AND 'MigrationUser' Users .... To be Used when we have no User Details
	BEGIN
		PRINT('');PRINT('*Create "UnknownUser" AND "MigrationUser" AND "Atlas System" Users');
		INSERT INTO dbo.[User] ([LoginId], [Password], [Name], [CreationTime], [Disabled], [LoginNotified])
		SELECT [LoginId], [Password], [Name], [CreationTime], [Disabled], [LoginNotified]
		FROM (
			SELECT 'UnknownUser' AS [LoginId]
				, 'Password' AS [Password]
				, 'Unknown User' AS [Name]
				, GETDATE() AS [CreationTime]
				, 'True' AS [Disabled]
				, 'True' AS [LoginNotified]
			UNION
			SELECT 'MigrationUser' AS [LoginId]
				, 'Password' AS [Password]
				, 'Migration' AS [Name]
				, GETDATE() AS [CreationTime]
				, 'True' AS [Disabled]
				, 'True' AS [LoginNotified]
			UNION
			SELECT 'AtlasSystem' AS [LoginId]
				, 'Password' AS [Password]
				, 'Atlas System' AS [Name]
				, GETDATE() AS [CreationTime]
				, 'True' AS [Disabled]
				, 'True' AS [LoginNotified]
			) AS NewUsers
		WHERE NOT EXISTS (SELECT * FROM .dbo.[User] U WHERE U.LoginId = NewUsers.LoginId);

		UPDATE SystemControl
		SET AtlasSystemUserId = (SELECT TOP 1 Id FROM [User] WHERE [Name] = 'Atlas System')
		;
	END

	
	BEGIN
		DECLARE @nowt int;

	END







	
PRINT('');PRINT('**Completed Script: "Migration_005.001_SetupRequiredDataBeforeMigrationBegins.sql"')
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/