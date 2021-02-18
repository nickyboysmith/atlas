
/*
	SCRIPT: Create a stored procedure to Create the Migration External Tables Linked to Old Atlas
	Author: Robert Newnham
	Created: 29/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_09.04_Create_uspDropMigrationConnectionToOldAtlasDB.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Drop the Migration Connection To Old Atlas DB';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDropMigrationConnectionToOldAtlasDB', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDropMigrationConnectionToOldAtlasDB;
END		
GO

/*
	Create uspDropMigrationConnectionToOldAtlasDB
*/
CREATE PROCEDURE uspDropMigrationConnectionToOldAtlasDB
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
	
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_09.04_Create_uspDropMigrationConnectionToOldAtlasDB.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO



