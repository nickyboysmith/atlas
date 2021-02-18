/*
	SCRIPT: Create Document Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_11.01_Create_Document.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Document Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'Document'
		
		/*
		 *	Create Document Table
		 */
		IF OBJECT_ID('dbo.Document', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Document;
		END

		CREATE TABLE Document(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [FileName] varchar(100) 
			, [OriginalFileName] varchar(100)
			, Title varchar(200) NOT NULL
			, [Description] varchar(400) NULL
			, UpdatedByUserId int NULL
			, DateUpdated DateTime
			, FileStoragePathId int
			, CONSTRAINT FK_Document_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Document_FileStoragePath FOREIGN KEY (FileStoragePathId) REFERENCES FileStoragePath(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;