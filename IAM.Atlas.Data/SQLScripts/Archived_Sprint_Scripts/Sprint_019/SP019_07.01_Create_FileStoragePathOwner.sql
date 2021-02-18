/*
	SCRIPT: Create FileStoragePathOwner Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_07.01_Create_FileStoragePathOwner.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FileStoragePathOwner Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FileStoragePathOwner'
		
		/*
		 *	Create FileStoragePathOwner Table
		 */
		IF OBJECT_ID('dbo.FileStoragePathOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FileStoragePathOwner;
		END

		CREATE TABLE FileStoragePathOwner(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, FileStoragePathId int NOT NULL
			, OrganisationId int
			, CONSTRAINT FK_FileStoragePathOwner_FileStoragePath FOREIGN KEY (FileStoragePathId) REFERENCES FileStoragePath(Id)
			, CONSTRAINT FK_FileStoragePathOwner_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;