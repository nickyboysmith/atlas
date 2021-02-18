/*
	SCRIPT: Create FileStoragePath Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_06.01_Create_FileStoragePath.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FileStoragePath Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FileStoragePath'
		
		/*
		 *	Create FileStoragePath Table
		 */
		IF OBJECT_ID('dbo.FileStoragePath', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FileStoragePath;
		END

		CREATE TABLE FileStoragePath(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100) NOT NULL
			, [Path] varchar(400) NOT NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;