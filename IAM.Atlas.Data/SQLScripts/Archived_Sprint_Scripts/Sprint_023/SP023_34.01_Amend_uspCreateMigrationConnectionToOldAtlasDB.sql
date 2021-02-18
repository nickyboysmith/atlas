
/*
	SCRIPT: Amend the SP to Create the Migration External Tables Linked to Old Atlas
	Author: Robert Newnham
	Created: 25/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_34.01_Amend_uspCreateMigrationConnectionToOldAtlasDB.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Create the Migration Connection To Old Atlas DB';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspCreateMigrationConnectionToOldAtlasDB', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspCreateMigrationConnectionToOldAtlasDB;
	END		
	GO

	/*
		Create uspCreateMigrationConnectionToOldAtlasDB
	*/
	CREATE PROCEDURE uspCreateMigrationConnectionToOldAtlasDB (@OldAtlasDatabaseName VARCHAR(40) = 'Old_Atlas')
	AS
	BEGIN
		BEGIN TRY
			--Drop if Exists
			DROP EXTERNAL DATA SOURCE IAM_Elastic_Old_Atlas;
		END TRY
		BEGIN CATCH
		END CATCH
		BEGIN TRY
			--Drop if Exists
			DROP DATABASE SCOPED CREDENTIAL ElasticDBQueryCred;
		END TRY
		BEGIN CATCH
		END CATCH
		BEGIN TRY
			--Drop if Exists
			DROP MASTER KEY;
		END TRY
		BEGIN CATCH
		END CATCH
	
		BEGIN TRY
			CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'IAM2015dev~!';

			CREATE DATABASE SCOPED CREDENTIAL ElasticDBQueryCred  
			WITH IDENTITY = 'AtlasDev@ymw3trna08',
			SECRET = 'IAM2015dev~!';

			CREATE EXTERNAL DATA SOURCE IAM_Elastic_Old_Atlas WITH
			  (TYPE = RDBMS,
			  LOCATION = 'tcp:ymw3trna08.database.windows.net,1433',
			  DATABASE_NAME = 'Old_Atlas',
			  CREDENTIAL = ElasticDBQueryCred
			) ;
		END TRY
		BEGIN CATCH
		END CATCH

	END
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_34.01_Amend_uspCreateMigrationConnectionToOldAtlasDB.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO



